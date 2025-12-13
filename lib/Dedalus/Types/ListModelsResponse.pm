package Dedalus::Types::ListModelsResponse;
use Moo;
use Types::Standard qw(ArrayRef Maybe Str InstanceOf);

use Dedalus::Types::Model;

has data => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Dedalus::Types::Model']],
    required => 1,
);

has object => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @models = map { Dedalus::Types::Model->from_hash($_) } @{ $hash->{data} || [] };
    return $class->new(
        data   => \@models,
        object => $hash->{object},
    );
}

1;
