package Dedalus::Types::Response::OutputContentBlock;
use Moo;
use Types::Standard qw(Str Maybe HashRef);

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'text' },
);

has text => (
    is  => 'ro',
    isa => Maybe[Str],
);

has raw => (
    is  => 'ro',
    isa => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        type => $hash->{type} // 'text',
        text => $hash->{text},
        raw  => $hash,
    );
}

1;
