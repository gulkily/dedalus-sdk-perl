package Dedalus::Async::Health;
use Moo;
use Future;

use Dedalus::Types::HealthCheckResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub check {
    my ($self, %opts) = @_;
    my $future = $self->client->request_future('GET', '/health', %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $data = $res->{data} || {};
        my $health = Dedalus::Types::HealthCheckResponse->from_hash($data);
        Future->done($health);
    });
}

1;
