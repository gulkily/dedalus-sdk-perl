package Dedalus::Types::Chat::ChunkChoice;
use Moo;
use Types::Standard qw(Int Maybe HashRef Str);

has delta => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has finish_reason => (
    is  => 'ro',
    isa => Maybe[Str],
);

has index => (
    is      => 'ro',
    isa     => Int,
    default => sub { 0 },
);

has logprobs => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    die 'delta is required' unless exists $hash->{delta};
    my $delta = $hash->{delta};
    die 'delta must be hash ref' unless ref $delta eq 'HASH';
    return $class->new(
        delta         => $delta,
        finish_reason => $hash->{finish_reason},
        index         => $hash->{index} // 0,
        logprobs      => $hash->{logprobs},
    );
}

1;
