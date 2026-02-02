package Dedalus::Types::Response::ImageURL;
use Moo;
use Types::Standard qw(Maybe Str HashRef);

has url => (
    is  => 'ro',
    isa => Maybe[Str],
);

has detail => (
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
        url    => $hash->{url},
        detail => $hash->{detail},
        raw    => $hash,
    );
}

1;
