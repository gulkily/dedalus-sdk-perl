package Dedalus::Types::Audio::TranslationCreateResponse;
use Moo;
use Types::Standard qw(Str Maybe Num HashRef ArrayRef InstanceOf);

use Dedalus::Types::Audio::Segment;

has text => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has format => (
    is  => 'ro',
    isa => Maybe[Str],
);

has language => (
    is  => 'ro',
    isa => Maybe[Str],
);

has duration => (
    is  => 'ro',
    isa => Maybe[Num],
);

has segments => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Audio::Segment']]],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';

    my $segments = _map_segments($hash->{segments});
    my $format   = $hash->{format};
    $format ||= 'verbose_json' if $segments || exists $hash->{language} || exists $hash->{duration};
    $format ||= 'json';

    return $class->new(
        text     => $hash->{text} // '',
        format   => $format,
        language => $hash->{language},
        duration => defined $hash->{duration} ? $hash->{duration} : undef,
        segments => $segments,
        raw      => $hash,
    );
}

sub _map_segments {
    my ($segments) = @_;
    return undef unless $segments && ref $segments eq 'ARRAY' && @$segments;
    my @mapped = map { Dedalus::Types::Audio::Segment->from_hash($_) } @$segments;
    return \@mapped;
}

1;
