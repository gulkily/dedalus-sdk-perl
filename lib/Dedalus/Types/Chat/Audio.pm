package Dedalus::Types::Chat::Audio;
use Moo;
use Types::Standard qw(Int Str);

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has expires_at => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has data => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has transcript => (
    is       => 'ro',
    isa      => Str,
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
    );
}

1;
