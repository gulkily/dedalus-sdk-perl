package Dedalus::Resources::Images;
use Moo;
use Carp qw(croak);

use Dedalus::Types::ImagesResponse;
use Dedalus::Types::Image::StreamEvent;
use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);
use Dedalus::Util::SSE qw(build_decoder);
use Dedalus::Stream;

has client => (
    is       => 'ro',
    required => 1,
);

my @GENERATE_KEYS = qw(
  prompt
  model
  n
  response_format
  size
  user
  quality
  style
  background
);

sub generate {
    my ($self, %params) = @_;
    croak 'prompt is required' unless $params{prompt};

    my $want_stream = delete $params{stream};

    my %body;
    for my $key (@GENERATE_KEYS) {
        next unless exists $params{$key};
        $body{$key} = $params{$key};
    }
    $body{stream} = \1 if $want_stream;

    if ($want_stream) {
        my $stream = Dedalus::Stream->new;
        my $decoder = build_decoder(sub {
            my ($event) = @_;
            if (defined $event) {
                my $chunk = Dedalus::Types::Image::StreamEvent->from_hash($event);
                $stream->push_chunk($chunk);
            } else {
                $stream->finish;
            }
        });

        my $guard = $self->client->http->stream_request(
            'POST',
            '/v1/images/generations',
            json     => \%body,
            on_chunk => sub {
                my ($chunk, $meta) = @_;
                if (defined $chunk) {
                    $decoder->($chunk);
                } else {
                    $stream->finish;
                }
            },
        );

        $stream->guard($guard);
        return $stream;
    }

    my $response = $self->client->request('POST', '/v1/images/generations', json => \%body);
    return Dedalus::Types::ImagesResponse->from_hash($response->{data} || {});
}

sub edit {
    my ($self, %params) = @_;
    croak 'image is required' unless $params{image};
    croak 'prompt is required' unless $params{prompt};

    my %fields = (
        image => normalize_file_field($params{image}, 'image.png', 'application/octet-stream'),
        prompt => $params{prompt},
    );
    $fields{mask}            = normalize_file_field($params{mask}, 'mask.png', 'application/octet-stream') if $params{mask};
    $fields{model}           = $params{model}           if $params{model};
    $fields{n}               = $params{n}               if defined $params{n};
    $fields{size}            = $params{size}            if $params{size};
    $fields{response_format} = $params{response_format} if $params{response_format};
    $fields{user}            = $params{user}            if $params{user};

    return $self->_multipart_request('/v1/images/edits', \%fields);
}

sub create_variation {
    my ($self, %params) = @_;
    croak 'image is required' unless $params{image};

    my %fields = (
        image => normalize_file_field($params{image}, 'image.png', 'application/octet-stream'),
    );
    $fields{model}           = $params{model}           if $params{model};
    $fields{n}               = $params{n}               if defined $params{n};
    $fields{size}            = $params{size}            if $params{size};
    $fields{response_format} = $params{response_format} if $params{response_format};
    $fields{user}            = $params{user}            if $params{user};

    return $self->_multipart_request('/v1/images/variations', \%fields);
}

sub _multipart_request {
    my ($self, $path, $fields) = @_;
    my ($boundary, $body) = build_multipart_body($fields);
    my $response = $self->client->request(
        'POST',
        $path,
        headers => { 'Content-Type' => "multipart/form-data; boundary=$boundary" },
        content => $body,
    );
    return Dedalus::Types::ImagesResponse->from_hash($response->{data} || {});
}

1;
