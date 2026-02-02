package Dedalus::Types::Shared::JSONSchema;
use Moo;
use Types::Standard qw(Str Maybe HashRef Bool);

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has description => (
    is  => 'ro',
    isa => Maybe[Str],
);

has schema => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has strict => (
    is  => 'ro',
    isa => Maybe[Bool],
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
        name        => $hash->{name},
        description => $hash->{description},
        schema      => $hash->{schema},
        strict      => $hash->{strict},
        raw         => $hash,
    );
}

1;
