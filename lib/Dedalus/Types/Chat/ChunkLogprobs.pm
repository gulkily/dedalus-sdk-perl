package Dedalus::Types::Chat::ChunkLogprobs;
use Moo;
use Types::Standard qw(ArrayRef InstanceOf Maybe);

use Dedalus::Types::Chat::CompletionTokenLogprob;

has content => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Chat::CompletionTokenLogprob']]],
);

has refusal => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Chat::CompletionTokenLogprob']]],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $content;
    if (exists $hash->{content} && ref $hash->{content} eq 'ARRAY') {
        my @items = map { Dedalus::Types::Chat::CompletionTokenLogprob->from_hash($_) } @{ $hash->{content} };
        $content = \@items;
    }
    my $refusal;
    if (exists $hash->{refusal} && ref $hash->{refusal} eq 'ARRAY') {
        my @items = map { Dedalus::Types::Chat::CompletionTokenLogprob->from_hash($_) } @{ $hash->{refusal} };
        $refusal = \@items;
    }
    return $class->new(
        content => $content,
        refusal => $refusal,
    );
}

1;
