package Dedalus::Types::Chat::Message;
use Moo;
use Scalar::Util qw(blessed);
use Types::Standard qw(Str Any ArrayRef Maybe InstanceOf HashRef);
use Dedalus::Types::Chat::ToolCall;
use Dedalus::Types::Chat::Audio;
use Dedalus::Types::Chat::Annotation;

has role => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has content => (
    is       => 'ro',
    isa      => Any,
    required => 1,
);

has refusal => (
    is  => 'ro',
    isa => Maybe[Str],
);

has tool_calls => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Chat::ToolCall']]],
);

has annotations => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Chat::Annotation']]],
);

has audio => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Chat::Audio']],
);

has function_call => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $tool_calls;
    if (exists $hash->{tool_calls} && ref $hash->{tool_calls} eq 'ARRAY') {
        my @calls = map { Dedalus::Types::Chat::ToolCall->from_hash($_) } @{ $hash->{tool_calls} };
        $tool_calls = \@calls;
    }
    my $annotations;
    if (exists $hash->{annotations} && ref $hash->{annotations} eq 'ARRAY') {
        my @items;
        for my $annotation (@{ $hash->{annotations} }) {
            if (blessed($annotation) && $annotation->isa('Dedalus::Types::Chat::Annotation')) {
                push @items, $annotation;
            } elsif (ref $annotation eq 'HASH') {
                push @items, Dedalus::Types::Chat::Annotation->from_hash($annotation);
            }
        }
        $annotations = \@items;
    }
    my $audio;
    if (exists $hash->{audio}) {
        if (blessed($hash->{audio}) && $hash->{audio}->isa('Dedalus::Types::Chat::Audio')) {
            $audio = $hash->{audio};
        } elsif (ref $hash->{audio} eq 'HASH') {
            $audio = Dedalus::Types::Chat::Audio->from_hash($hash->{audio});
        }
    }
    return $class->new(
        role          => $hash->{role} // 'assistant',
        content       => $hash->{content},
        refusal       => $hash->{refusal},
        tool_calls    => $tool_calls,
        annotations   => $annotations,
        audio         => $audio,
        function_call => $hash->{function_call},
    );
}

1;
