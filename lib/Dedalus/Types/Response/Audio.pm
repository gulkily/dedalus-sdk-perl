package Dedalus::Types::Response::Audio;
use Moo;
use Types::Standard qw(Maybe Str Int HashRef);

has id => (
    is  => 'ro',
    isa => Maybe[Str],
);

has expires_at => (
    is  => 'ro',
    isa => Maybe[Int],
);

has data => (
    is  => 'ro',
    isa => Maybe[Str],
);

has transcript => (
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
        id         => $hash->{id},
        expires_at => $hash->{expires_at},
        data       => $hash->{data},
        transcript => $hash->{transcript},
        raw        => $hash,
    );
}

1;
