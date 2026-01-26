package Dedalus::Types::RootGetResponse;
use Moo;
use Types::Standard qw(Maybe Str HashRef);

has message => (
    is  => 'ro',
    isa => Maybe[Str],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        message => $hash->{message},
        raw     => $hash,
    );
}

1;
