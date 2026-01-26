package Dedalus::Resources::Root;
use Moo;

use Dedalus::Types::RootGetResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub get {
    my ($self, %opts) = @_;
    my $response = $self->client->request('GET', '/', %opts);
    my $data = $response->{data} // {};
    return Dedalus::Types::RootGetResponse->from_hash($data);
}

1;
