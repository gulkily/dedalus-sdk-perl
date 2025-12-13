package Dedalus::Resources::Models;
use Moo;
use Carp qw(croak);

use Dedalus::Types::Model;
use Dedalus::Types::ListModelsResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub retrieve {
    my ($self, $model_id, %opts) = @_;
    croak 'model_id is required' unless $model_id;
    my $response = $self->client->request('GET', "/v1/models/$model_id", %opts);
    my $data = $response->{data} || {};
    return Dedalus::Types::Model->from_hash($data);
}

sub list {
    my ($self, %opts) = @_;
    my $response = $self->client->request('GET', '/v1/models', %opts);
    my $data = $response->{data} || {};
    return Dedalus::Types::ListModelsResponse->from_hash($data);
}

1;
