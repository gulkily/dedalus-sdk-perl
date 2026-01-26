package Dedalus::Types::Runner::ToolResult;
use Moo;
use Types::Standard qw(Int Maybe Str Any HashRef);

has name => (
    is  => 'ro',
    isa => Maybe[Str],
);

has result => (
    is  => 'ro',
    isa => Any,
);

has step => (
    is  => 'ro',
    isa => Maybe[Int],
);

has error => (
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
        name   => $hash->{name},
        result => $hash->{result},
        step   => $hash->{step},
        error  => $hash->{error},
        raw    => $hash,
    );
}

1;
