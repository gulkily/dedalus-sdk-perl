package Dedalus::HTTP;
use Moo;
use HTTP::Tiny;
use URI;
use Try::Tiny;
use Time::HiRes qw(usleep);
use Cpanel::JSON::XS qw(encode_json decode_json);
use AnyEvent;
use AnyEvent::HTTP;

use Dedalus::Exception::APIConnectionError;
use Dedalus::Exception::APITimeoutError;
use Dedalus::Exception::BadRequestError;
use Dedalus::Exception::AuthenticationError;
use Dedalus::Exception::PermissionDeniedError;
use Dedalus::Exception::NotFoundError;
use Dedalus::Exception::RateLimitError;
use Dedalus::Exception::InternalServerError;
use Dedalus::Exception::APIStatusError;
use Dedalus::Util::QS qw(stringify);

has config => (
    is       => 'ro',
    required => 1,
);

has max_retries => (
    is      => 'ro',
    default => sub { 2 },
);

has _http => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_http',
);

sub _build_http {
    my ($self) = @_;
    return HTTP::Tiny->new(
        agent           => $self->config->headers->{'User-Agent'},
        timeout         => $self->config->timeout,
        default_headers => {},
    );
}

sub request {
    my ($self, $method, $path, %opts) = @_;
    $method = uc $method;
    my $url = $self->_build_url($path, $opts{query});
    my %headers = %{ $self->config->headers };
    if (my $extra = $opts{headers}) {
        %headers = (%headers, %{$extra});
    }

    my $content;
    if (exists $opts{json}) {
        $headers{'Content-Type'} ||= 'application/json';
        $content = encode_json($opts{json});
    } elsif (defined $opts{content}) {
        $content = $opts{content};
    }

    my $attempt = 0;
    my $response;
    while (1) {
        $response = $self->_http->request($method, $url, {
            headers => \%headers,
            content => $content,
        });

        last if $response->{success};
        last unless $self->_should_retry($response->{status});
        last if $attempt >= $self->max_retries;
        $attempt++;
        my $delay = (2 ** $attempt) * 0.25;
        usleep($delay * 1_000_000);
    }

    return $self->_handle_response($response, $method, $url);
}

sub stream_request {
    my ($self, $method, $path, %opts) = @_;
    my $on_chunk = delete $opts{on_chunk} or die 'on_chunk callback required';
    $method = uc $method;
    my $url = $self->_build_url($path, $opts{query});
    my %headers = %{ $self->config->headers };
    if (my $extra = $opts{headers}) {
        %headers = (%headers, %{$extra});
    }

    my $content;
    if (exists $opts{json}) {
        $headers{'Content-Type'} ||= 'application/json';
        $content = encode_json($opts{json});
    } elsif (defined $opts{content}) {
        $content = $opts{content};
    }

    my $guard;
    $guard = http_request $method => $url,
        headers => \%headers,
        body    => $content,
        on_body => sub {
            my ($chunk, $hdr) = @_;
            return 1 unless defined $chunk && length $chunk;
            $on_chunk->($chunk);
            return 1;
        },
        sub {
            my ($body, $hdr) = @_;
            $on_chunk->(undef, $hdr);
        };

    return $guard;
}

sub _build_url {
    my ($self, $path, $query) = @_;
    my $base = URI->new($self->config->base_url);
    my $clone = $base->clone;
    my $base_path = $clone->path // '';
    $base_path =~ s{/+$}{};
    $path ||= '';
    $path =~ s{^/}{};
    my $full_path = join '/', grep { length } ($base_path, $path);
    $clone->path('/' . $full_path);
    if ($query && ref $query eq 'HASH' && %{$query}) {
        my $qs = stringify($query);
        $clone->query($qs) if length $qs;
    }
    return $clone->as_string;
}

sub _should_retry {
    my ($self, $status) = @_;
    return 1 if !defined $status || $status == 0;
    return 1 if $status == 408 || $status == 409 || $status == 429;
    return 1 if $status >= 500;
    return 0;
}

sub _handle_response {
    my ($self, $response, $method, $url) = @_;
    unless ($response->{success}) {
        $self->_raise_error($response);
    }

    my $content = $response->{content} // '';
    my $data;
    if (length $content && ($response->{headers}{'content-type'} // '') =~ m{application/json}i) {
        $data = try { decode_json($content) } catch { undef };
    }

    return {
        status  => $response->{status},
        headers => $response->{headers},
        data    => $data,
        content => $content,
    };
}

sub _raise_error {
    my ($self, $response) = @_;
    my $status = $response->{status};
    my $content = $response->{content};
    my $body;
    try {
        $body = decode_json($content) if defined $content && length $content;
    } catch {
        $body = { error => $content } if defined $content;
    };

    my %args = (
        message     => $body->{error}{message} // $response->{reason} // 'Dedalus API request failed',
        http_status => $status,
        body        => $body,
    );

    my $class = 'Dedalus::Exception::APIStatusError';
    if (!defined $status) {
        $class = 'Dedalus::Exception::APIConnectionError';
    } elsif ($status == 400) {
        $class = 'Dedalus::Exception::BadRequestError';
    } elsif ($status == 401) {
        $class = 'Dedalus::Exception::AuthenticationError';
    } elsif ($status == 403) {
        $class = 'Dedalus::Exception::PermissionDeniedError';
    } elsif ($status == 404) {
        $class = 'Dedalus::Exception::NotFoundError';
    } elsif ($status == 408) {
        $class = 'Dedalus::Exception::APITimeoutError';
    } elsif ($status == 409 || $status == 429) {
        $class = 'Dedalus::Exception::RateLimitError';
    } elsif ($status && $status >= 500) {
        $class = 'Dedalus::Exception::InternalServerError';
    }

    die $class->new(%args);
}

1;
