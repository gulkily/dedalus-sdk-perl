package Dedalus::Resources::Chat::Completions;
use Moo;
use Carp qw(croak);

use Dedalus::Types::Chat::Completion;
use Dedalus::Stream;
use Dedalus::Util::SSE qw(to_stream_events);

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

    my $response = $self->client->request(
        'POST',
        '/v1/chat/completions',
        %request_opts,
        json => \%body,
    );

    if ($body{stream}) {
        my $events = to_stream_events($response->{content});
        return Dedalus::Stream->new(events => $events);
    }

    my $data = $response->{data} || {};
    return Dedalus::Types::Chat::Completion->from_hash($data);
}

1;
