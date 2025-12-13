package Dedalus::Types::CreateEmbeddingResponse;
use Moo;
use Types::Standard qw(Str HashRef ArrayRef InstanceOf Maybe);

use Dedalus::Types::Embeddings::Data;

has data => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Dedalus::Types::Embeddings::Data']],
    required => 1,
);

has model => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has usage => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has object => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @data = map { Dedalus::Types::Embeddings::Data->from_hash($_) } @{ $hash->{data} || [] };
    return $class->new(
        data   => \@data,
        model  => $hash->{model} // '',
        usage  => $hash->{usage} || {},
        object => $hash->{object},
    );
}

1;
