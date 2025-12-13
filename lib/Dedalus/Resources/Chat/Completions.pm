package Dedalus::Resources::Chat::Completions;
use Moo;
use Carp qw(croak);

use Dedalus::Types::Chat::Completion;
use Dedalus::Stream;
use Dedalus::Util::SSE qw(to_stream_events build_decoder);

has client => (
    is       => 'ro',
    required => 1,
);

my @ALLOWED_BODY_KEYS = qw(
  model
  messages
  temperature
  max_tokens
  user
  metadata
  stream
  response_format
  tools
  tool_choice
  logprobs
  top_logprobs
);

sub create {
    my ($self, %params) = @_;
    croak 'model is required'    unless $params{model};
    croak 'messages must be arrayref'
      unless ref $params{messages} eq 'ARRAY';

    my %body;
    for my $key (@ALLOWED_BODY_KEYS) {
        next unless exists $params{$key};
        $body{$key} = $params{$key};
    }

    my %request_opts;
    if (my $extra = delete $params{extra_headers}) {
        $request_opts{headers} = $extra;
    }

    if ($body{stream}) {
        my $stream = Dedalus::Stream->new;
        my $decoder = build_decoder(sub {
            my ($event) = @_;
            if (defined $event) {
                $stream->push_chunk($event);
            } else {
                $stream->finish;
            }
        });

        my $guard = $self->client->stream_request(
            'POST',
            '/v1/chat/completions',
            %request_opts,
            json => \%body,
            on_chunk => sub {
                my ($chunk, $meta) = @_;
                if (defined $chunk) {
                    $decoder->($chunk);
                } else {
                    if ($meta && $meta->{Status} && $meta->{Status} >= 400) {
                        $stream->push_chunk({ error => $meta->{Reason} });
                    }
                    $stream->finish;
                }
            },
        );

        $stream->guard($guard);
        return $stream;
    }

    my $response = $self->client->request(
        'POST',
        '/v1/chat/completions',
        %request_opts,
        json => \%body,
    );

    my $data = $response->{data} || {};
    return Dedalus::Types::Chat::Completion->from_hash($data);
}

1;
