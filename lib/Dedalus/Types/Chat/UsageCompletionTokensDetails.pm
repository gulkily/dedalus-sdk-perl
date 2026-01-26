package Dedalus::Types::Chat::UsageCompletionTokensDetails;
use Moo;
use Types::Standard qw(Int Maybe);

has accepted_prediction_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has audio_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has reasoning_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has rejected_prediction_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        accepted_prediction_tokens => $hash->{accepted_prediction_tokens},
        audio_tokens               => $hash->{audio_tokens},
        reasoning_tokens           => $hash->{reasoning_tokens},
        rejected_prediction_tokens => $hash->{rejected_prediction_tokens},
    );
}

1;
