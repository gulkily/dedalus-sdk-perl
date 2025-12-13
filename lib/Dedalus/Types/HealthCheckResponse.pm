package Dedalus::Types::HealthCheckResponse;
use Moo;

has status => (
    is       => 'ro',
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(status => $hash->{status});
}

1;
