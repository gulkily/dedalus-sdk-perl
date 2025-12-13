package Dedalus::Resources::Health;
use Moo;

use Dedalus::Types::HealthCheckResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub check {
    my ($self, %opts) = @_;
    my $response = $self->client->request('GET', '/health', %opts);
    my $data = $response->{data} // {};
    return Dedalus::Types::HealthCheckResponse->from_hash($data);
}

1;
