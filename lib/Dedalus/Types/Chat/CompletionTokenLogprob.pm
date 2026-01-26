package Dedalus::Types::Chat::CompletionTokenLogprob;
use Moo;
use Types::Standard qw(ArrayRef Int Maybe Num Str InstanceOf);

use Dedalus::Types::Chat::TopLogprob;

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

has top_logprobs => (
    is      => 'ro',
    isa     => ArrayRef[InstanceOf['Dedalus::Types::Chat::TopLogprob']],
    default => sub { [] },
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @top = map { Dedalus::Types::Chat::TopLogprob->from_hash($_) } @{ $hash->{top_logprobs} || [] };
    return $class->new(
        token        => $hash->{token} // '',
        bytes        => $hash->{bytes},
        logprob      => $hash->{logprob} // 0,
        top_logprobs => \@top,
    );
}

1;
