package Dedalus::Async::Embeddings;
use Moo;
use Future;

use Dedalus::Types::CreateEmbeddingResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    my $future = $self->client->request_future('POST', '/v1/embeddings', json => \%params);
    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::CreateEmbeddingResponse->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

1;
