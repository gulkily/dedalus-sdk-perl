package Dedalus::Types::Image::Partial;
use Moo;
use Types::Standard qw(Int Maybe Str);

has index => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has status => (
    is  => 'ro',
    isa => Maybe[Str],
);

has b64_json => (
    is  => 'ro',
    isa => Maybe[Str],
);

has url => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        index    => $hash->{index} // 0,
        status   => $hash->{status},
        b64_json => $hash->{b64_json},
        url      => $hash->{url},
    );
}

1;
