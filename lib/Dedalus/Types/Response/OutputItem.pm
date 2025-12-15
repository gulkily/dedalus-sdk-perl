package Dedalus::Types::Response::OutputItem;
use Moo;
use Types::Standard qw(Str Maybe ArrayRef InstanceOf);

use Dedalus::Types::Response::OutputContentBlock;

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'message' },
);

has role => (
    is  => 'ro',
    isa => Maybe[Str],
);

has content => (
    is      => 'ro',
    isa     => ArrayRef[InstanceOf['Dedalus::Types::Response::OutputContentBlock']],
    default => sub { [] },
);

has raw => (
    is       => 'ro',
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @content = map { Dedalus::Types::Response::OutputContentBlock->from_hash($_) } @{ $hash->{content} || [] };
    return $class->new(
        type    => $hash->{type} // 'message',
        role    => $hash->{role},
        content => \@content,
        raw     => $hash,
    );
}

1;
