package Dedalus::Types::Chat::ToolCall;
use Moo;
use Types::Standard qw(Str Maybe HashRef);

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'function' },
);

has id => (
    is  => 'ro',
    isa => Maybe[Str],
);

has function => (
    is  => 'ro',
    isa => Maybe[HashRef],
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
        type     => $hash->{type} // 'function',
        id       => $hash->{id},
        function => $hash->{function},
        raw      => $hash,
    );
}

1;
