package Dedalus::Types::Image;
use Moo;
use Types::Standard qw(Maybe Str);

has url => (
    is  => 'ro',
    isa => Maybe[Str],
);

has b64_json => (
    is  => 'ro',
    isa => Maybe[Str],
);

has revised_prompt => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        url            => $hash->{url},
        b64_json       => $hash->{b64_json},
        revised_prompt => $hash->{revised_prompt},
    );
}

1;
