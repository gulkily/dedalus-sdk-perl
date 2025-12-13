package Dedalus::Types::Audio::TranscriptionCreateResponse;
use Moo;
use Types::Standard qw(Str ArrayRef HashRef Maybe);

has text => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has segments => (
    is      => 'ro',
    isa     => Maybe[ArrayRef[HashRef]],
);

has language => (
    is  => 'ro',
    isa => Maybe[Str],
);

has duration => (
    is  => 'ro',
    isa => Maybe[Str],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        text     => $hash->{text} // '',
        segments => $hash->{segments},
        language => $hash->{language},
        duration => $hash->{duration},
        raw      => $hash,
    );
}

1;
