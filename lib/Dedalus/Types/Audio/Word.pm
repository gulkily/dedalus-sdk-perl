package Dedalus::Types::Audio::Word;
use Moo;
use Types::Standard qw(Num Maybe Str);

has word => (
    is  => 'ro',
    isa => Maybe[Str],
);

has start => (
    is  => 'ro',
    isa => Maybe[Num],
);

has end => (
    is  => 'ro',
    isa => Maybe[Num],
);

has probability => (
    is  => 'ro',
    isa => Maybe[Num],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        word        => $hash->{word},
        start       => $hash->{start},
        end         => $hash->{end},
        probability => $hash->{probability},
    );
}

1;
