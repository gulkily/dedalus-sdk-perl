package Dedalus::Types::Chat::UsagePromptTokensDetails;
use Moo;
use Types::Standard qw(Int Maybe);

has audio_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has cached_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        audio_tokens  => $hash->{audio_tokens},
        cached_tokens => $hash->{cached_tokens},
    );
}

1;
