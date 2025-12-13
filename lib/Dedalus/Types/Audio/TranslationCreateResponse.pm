package Dedalus::Types::Audio::TranslationCreateResponse;
use Moo;
use Types::Standard qw(Str HashRef);

has text => (
    is       => 'ro',
    isa      => Str,
    required => 1,
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
        text => $hash->{text} // '',
        raw  => $hash,
    );
}

1;
