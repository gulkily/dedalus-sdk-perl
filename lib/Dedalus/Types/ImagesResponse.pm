package Dedalus::Types::ImagesResponse;
use Moo;
use Types::Standard qw(Int ArrayRef InstanceOf);

use Dedalus::Types::Image;

has created => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has data => (
    is       => 'ro',
    isa      => ArrayRef[InstanceOf['Dedalus::Types::Image']],
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @images = map { Dedalus::Types::Image->from_hash($_) } @{ $hash->{data} || [] };
    return $class->new(
        created => $hash->{created} // 0,
        data    => \@images,
    );
}

1;
