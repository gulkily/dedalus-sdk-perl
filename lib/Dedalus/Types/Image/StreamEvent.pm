package Dedalus::Types::Image::StreamEvent;
use Moo;
use Types::Standard qw(Str Maybe Int InstanceOf HashRef);

use Dedalus::Types::Image::Partial;

has type => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has index => (
    is  => 'ro',
    isa => Maybe[Int],
);

has image => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Image::Partial']],
);

has event => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $image;
    if (exists $hash->{image} && ref $hash->{image} eq 'HASH') {
        $image = Dedalus::Types::Image::Partial->from_hash($hash->{image});
    }
    return $class->new(
        type  => $hash->{type} // 'image.partial',
        index => $hash->{index},
        image => $image,
        event => $hash,
    );
}

1;
