package Dedalus::Types::Audio::TranscriptionCreateResponse;
use Moo;
use Types::Standard qw(Str Maybe ArrayRef InstanceOf HashRef Num);

use Dedalus::Types::Audio::Segment;
use Dedalus::Types::Audio::Word;
use Dedalus::Types::Audio::TranscriptionLogprob;
use Dedalus::Types::Audio::TranscriptionUsage;

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

has words => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Audio::Word']]],
);

has logprobs => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Audio::TranscriptionLogprob']]],
);

has usage => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Audio::TranscriptionUsage']],
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
    my $words    = _map_words($hash->{words});
    my $logprobs = _map_logprobs($hash->{logprobs});
    my $usage;
    if (exists $hash->{usage} && ref $hash->{usage} eq 'HASH') {
        $usage = Dedalus::Types::Audio::TranscriptionUsage->from_hash($hash->{usage});
    }
    my $format   = $hash->{format};
    $format ||= 'verbose_json' if $segments || $words || exists $hash->{language} || exists $hash->{duration};
    $format ||= 'json';

    return $class->new(
        text     => $hash->{text} // '',
        format   => $format,
        language => $hash->{language},
        duration => defined $hash->{duration} ? $hash->{duration} : undef,
        segments => $segments,
        words    => $words,
        logprobs => $logprobs,
        usage    => $usage,
        raw      => $hash,
    );
}

sub _map_segments {
    my ($segments) = @_;
    return undef unless $segments && ref $segments eq 'ARRAY' && @$segments;
    my @mapped = map { Dedalus::Types::Audio::Segment->from_hash($_) } @$segments;
    return \@mapped;
}

sub _map_words {
    my ($words) = @_;
    return undef unless $words && ref $words eq 'ARRAY' && @$words;
    my @mapped = map { Dedalus::Types::Audio::Word->from_hash($_) } @$words;
    return \@mapped;
}

sub _map_logprobs {
    my ($logprobs) = @_;
    return undef unless $logprobs && ref $logprobs eq 'ARRAY' && @$logprobs;
    my @mapped = map { Dedalus::Types::Audio::TranscriptionLogprob->from_hash($_) } @$logprobs;
    return \@mapped;
}

1;
