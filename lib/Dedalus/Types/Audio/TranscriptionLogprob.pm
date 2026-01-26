package Dedalus::Types::Audio::TranscriptionLogprob;
use Moo;
use Types::Standard qw(Num Maybe Str ArrayRef Int);

has token => (
    is  => 'ro',
    isa => Maybe[Str],
);

has bytes => (
    is  => 'ro',
    isa => Maybe[ArrayRef[Int]],
);

has logprob => (
    is  => 'ro',
    isa => Maybe[Num],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        token   => $hash->{token},
        bytes   => $hash->{bytes},
        logprob => $hash->{logprob},
    );
}

1;
