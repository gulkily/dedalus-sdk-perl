package Dedalus::Types::Chat::Annotation;
use Moo;
use Types::Standard qw(Str Maybe InstanceOf HashRef);

use Dedalus::Types::Chat::Annotation::URLCitation;

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'url_citation' },
);

has url_citation => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Chat::Annotation::URLCitation']],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $url_citation;
    if (exists $hash->{url_citation} && ref $hash->{url_citation} eq 'HASH') {
        $url_citation = Dedalus::Types::Chat::Annotation::URLCitation->from_hash($hash->{url_citation});
    }
    return $class->new(
        type         => $hash->{type} // 'url_citation',
        url_citation => $url_citation,
        raw          => $hash,
    );
}

1;
