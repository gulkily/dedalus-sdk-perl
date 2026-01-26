package Dedalus::Types::Audio::TranscriptionUsageInputTokenDetails;
use Moo;
use Types::Standard qw(Int Maybe);

has audio_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has text_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        audio_tokens => $hash->{audio_tokens},
        text_tokens  => $hash->{text_tokens},
    );
}

1;
