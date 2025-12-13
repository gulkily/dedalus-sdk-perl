package Dedalus::Async::Responses;
use Moo;
use Future;
use Carp qw(croak);

use Dedalus::Types::Response;

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
    croak 'model is required' unless $params{model};
    croak 'input is required' unless exists $params{input};

    my %body;
    for my $key (@ALLOWED_PARAMS) {
        next unless exists $params{$key};
        $body{$key} = $params{$key};
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
