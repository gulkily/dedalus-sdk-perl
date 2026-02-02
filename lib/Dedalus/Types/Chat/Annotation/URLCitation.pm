package Dedalus::Types::Chat::Annotation::URLCitation;
use Moo;
use Types::Standard qw(Int Str);

has start_index => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has end_index => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has title => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has url => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        start_index => $hash->{start_index},
        end_index   => $hash->{end_index},
        title       => $hash->{title},
        url         => $hash->{url},
    );
}

1;
