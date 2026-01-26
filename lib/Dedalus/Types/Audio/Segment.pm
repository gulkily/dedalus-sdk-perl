package Dedalus::Types::Audio::Segment;
use Moo;
use Types::Standard qw(Int Num Maybe Str ArrayRef);

has id => (
    is  => 'ro',
    isa => Maybe[Int],
);

has seek => (
    is  => 'ro',
    isa => Maybe[Int],
);

has start => (
    is  => 'ro',
    isa => Maybe[Num],
);

has end => (
    is  => 'ro',
    isa => Maybe[Num],
);

has text => (
    is  => 'ro',
    isa => Maybe[Str],
);

has tokens => (
    is  => 'ro',
    isa => Maybe[ArrayRef[Int]],
);

has temperature => (
    is  => 'ro',
    isa => Maybe[Num],
);

has avg_logprob => (
    is  => 'ro',
    isa => Maybe[Num],
);

has compression_ratio => (
    is  => 'ro',
    isa => Maybe[Num],
);

has no_speech_prob => (
    is  => 'ro',
    isa => Maybe[Num],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        id                => $hash->{id},
        seek              => $hash->{seek},
        start             => $hash->{start},
        end               => $hash->{end},
        text              => $hash->{text},
        tokens            => $hash->{tokens},
        temperature       => $hash->{temperature},
        avg_logprob       => $hash->{avg_logprob},
        compression_ratio => $hash->{compression_ratio},
        no_speech_prob    => $hash->{no_speech_prob},
    );
}

1;
