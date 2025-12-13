package Dedalus::Async::Models;
use Moo;
use Future;

use Dedalus::Types::Model;
use Dedalus::Types::ListModelsResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub retrieve {
    my ($self, $model_id, %opts) = @_;
    die 'model_id is required' unless $model_id;
    my $future = $self->client->request_future('GET', "/v1/models/$model_id", %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $data = $res->{data} || {};
        my $model = Dedalus::Types::Model->from_hash($data);
        Future->done($model);
    });
}

sub list {
    my ($self, %opts) = @_;
    my $future = $self->client->request_future('GET', '/v1/models', %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $data = $res->{data} || {};
        my $list = Dedalus::Types::ListModelsResponse->from_hash($data);
        Future->done($list);
    });
}

1;
