package Dedalus::Types::Response::StreamEvent;
use Moo;
use Types::Standard qw(Str Maybe HashRef);

has type => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has delta => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has parsed => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has event => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        type  => $hash->{type} // 'content.delta',
        delta => $hash->{delta},
        parsed => $hash->{parsed},
        event => $hash,
    );
}

1;
