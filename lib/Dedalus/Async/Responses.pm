package Dedalus::Async::Responses;
use Moo;
use Future;
use Carp qw(croak);

use Dedalus::Types::Response;
use Dedalus::Types::Response::StreamEvent;
use Dedalus::Util::Params qw(require_params ensure_arrayref);
use Dedalus::Stream;
use Dedalus::Util::SSE qw(build_decoder);

has client => (
    is       => 'ro',
    required => 1,
);

my @ALLOWED_PARAMS = qw(
  input
  instructions
  model
  metadata
  max_output_tokens
  response_format
  temperature
  top_p
  top_k
  frequency_penalty
  presence_penalty
  tools
  parallel_tool_calls
  reasoning
);

sub create {
    my ($self, %params) = @_;
    require_params(\%params, qw(model input));

    my $want_stream = delete $params{stream};

    my %body;
    for my $key (@ALLOWED_PARAMS) {
        next unless exists $params{$key};
        $body{$key} = $params{$key};
    }
    $body{input} = ensure_arrayref($body{input}, 'input');
    $body{stream} = \1 if $want_stream;

    if ($want_stream) {
        my $stream = Dedalus::Stream->new;
        my $decoder = build_decoder(sub {
            my ($event) = @_;
            if (defined $event) {
                my $chunk = Dedalus::Types::Response::StreamEvent->from_hash($event);
                $stream->push_chunk($chunk);
            } else {
                $stream->finish;
            }
        });

        my $http = $self->client->http;
        my $guard = $http->stream_request(
            'POST',
            '/v1/responses',
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
        return Future->done($stream);
    }

    my $future = $self->client->request_future('POST', '/v1/responses', json => \%body);
    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::Response->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

sub retrieve {
    my ($self, $response_id, %opts) = @_;
    croak 'response_id is required' unless $response_id;
    my $future = $self->client->request_future('GET', "/v1/responses/$response_id", %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::Response->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

1;
