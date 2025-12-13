package Dedalus::Types::Embeddings::Data;
use Moo;
use Types::Standard qw(Int Str ArrayRef Num Maybe Ref);

has embedding => (
    is       => 'ro',
    required => 1,
);

has index => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has object => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $embedding = $hash->{embedding};
    $embedding = [ @{ $embedding || [] } ] if ref $embedding eq 'ARRAY';

    return $class->new(
        embedding => $embedding,
        index     => $hash->{index} // 0,
        object    => $hash->{object},
    );
}

1;
