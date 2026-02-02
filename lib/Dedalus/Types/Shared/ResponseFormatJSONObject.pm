package Dedalus::Types::Shared::ResponseFormatJSONObject;
use Moo;
use Types::Standard qw(Str HashRef);

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'json_object' },
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
        type => $hash->{type} // 'json_object',
        raw  => $hash,
    );
}

1;
