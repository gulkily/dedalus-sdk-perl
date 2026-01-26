package Dedalus::Types::Chat::TopLogprob;
use Moo;
use Types::Standard qw(ArrayRef Int Maybe Num Str);

has token => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has bytes => (
    is  => 'ro',
    isa => Maybe[ArrayRef[Int]],
);

has logprob => (
    is       => 'ro',
    isa      => Num,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        token   => $hash->{token} // '',
        bytes   => $hash->{bytes},
        logprob => $hash->{logprob} // 0,
    );
}

1;
