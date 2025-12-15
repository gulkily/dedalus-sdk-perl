package Dedalus::Async::Images;
use Moo;
use Future;

use Dedalus::Types::ImagesResponse;
use Dedalus::Types::Image::StreamEvent;
use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);
use Dedalus::Util::SSE qw(build_decoder);
use Dedalus::Stream;

has client => (
    is       => 'ro',
    required => 1,
);

sub generate {
    my ($self, %params) = @_;
    my $want_stream = delete $params{stream};
    $params{stream} = \1 if $want_stream;

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
            json     => \%params,
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
        return Future->done($stream);
    }

    my $future = $self->client->request_future('POST', '/v1/images/generations', json => \%params);
    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::ImagesResponse->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

sub edit {
    my ($self, %params) = @_;
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

    my ($boundary, $body) = build_multipart_body(\%fields);

    my $future = $self->client->request_future(
        'POST',
        '/v1/images/edits',
        headers => { 'Content-Type' => "multipart/form-data; boundary=$boundary" },
        content => $body,
    );

    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::ImagesResponse->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

sub create_variation {
    my ($self, %params) = @_;
    my %fields = (
        image => normalize_file_field($params{image}, 'image.png', 'application/octet-stream'),
    );
    $fields{model}           = $params{model}           if $params{model};
    $fields{n}               = $params{n}               if defined $params{n};
    $fields{size}            = $params{size}            if $params{size};
    $fields{response_format} = $params{response_format} if $params{response_format};
    $fields{user}            = $params{user}            if $params{user};

    my ($boundary, $body) = build_multipart_body(\%fields);

    my $future = $self->client->request_future(
        'POST',
        '/v1/images/variations',
        headers => { 'Content-Type' => "multipart/form-data; boundary=$boundary" },
        content => $body,
    );

    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::ImagesResponse->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

1;
