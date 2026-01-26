package Dedalus::Async::Root;
use Moo;
use Future;

use Dedalus::Types::RootGetResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub get {
    my ($self, %opts) = @_;
    my $future = $self->client->request_future('GET', '/', %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $data = $res->{data} || {};
        my $root = Dedalus::Types::RootGetResponse->from_hash($data);
        Future->done($root);
    });
}

1;
