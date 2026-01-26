package Dedalus::Types::Chat::ChunkChoice;
use Moo;
use Scalar::Util qw(blessed);
use Types::Standard qw(Int Maybe HashRef Str InstanceOf);

use Dedalus::Types::Chat::ChunkLogprobs;

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
    isa => Maybe[InstanceOf['Dedalus::Types::Chat::ChunkLogprobs']],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    die 'delta is required' unless exists $hash->{delta};
    my $delta = $hash->{delta};
    die 'delta must be hash ref' unless ref $delta eq 'HASH';
    my $logprobs;
    if (exists $hash->{logprobs}) {
        if (ref $hash->{logprobs} eq 'HASH') {
            $logprobs = Dedalus::Types::Chat::ChunkLogprobs->from_hash($hash->{logprobs});
        } elsif (blessed($hash->{logprobs}) && $hash->{logprobs}->isa('Dedalus::Types::Chat::ChunkLogprobs')) {
            $logprobs = $hash->{logprobs};
        }
    }
    return $class->new(
        delta         => $delta,
        finish_reason => $hash->{finish_reason},
        index         => $hash->{index} // 0,
        logprobs      => $logprobs,
    );
}

1;
