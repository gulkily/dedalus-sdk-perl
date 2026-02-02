package Dedalus::Types::Chat::ParsedChatCompletionMessage;
use Moo;
use Scalar::Util qw(blessed);
use Types::Standard qw(Any ArrayRef HashRef InstanceOf Maybe Str);

use Dedalus::Types::Chat::Audio;
use Dedalus::Types::Chat::Annotation;
use Dedalus::Types::Chat::ParsedFunctionToolCall;

has role => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has content => (
    is  => 'ro',
    isa => Any,
);

has parsed => (
    is  => 'ro',
    isa => Maybe[Any],
);

has refusal => (
    is  => 'ro',
    isa => Maybe[Str],
);

has tool_calls => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Chat::ParsedFunctionToolCall']]],
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

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $tool_calls;
    if (exists $hash->{tool_calls} && ref $hash->{tool_calls} eq 'ARRAY') {
        my @calls = map { Dedalus::Types::Chat::ParsedFunctionToolCall->from_hash($_) } @{ $hash->{tool_calls} };
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
        parsed        => $hash->{parsed},
        refusal       => $hash->{refusal},
        tool_calls    => $tool_calls,
        annotations   => $annotations,
        audio         => $audio,
        function_call => $hash->{function_call},
        raw           => $hash,
    );
}

1;

package Dedalus::Types::Chat::ParsedChoice;
use Moo;
use Scalar::Util qw(blessed);
use Types::Standard qw(Int Maybe Str InstanceOf);

use Dedalus::Types::Chat::ChoiceLogprobs;

has index => (
    is      => 'ro',
    isa     => Int,
    default => sub { 0 },
);

has finish_reason => (
    is  => 'ro',
    isa => Maybe[Str],
);

has message => (
    is       => 'ro',
    isa      => InstanceOf['Dedalus::Types::Chat::ParsedChatCompletionMessage'],
    required => 1,
);

has logprobs => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Chat::ChoiceLogprobs']],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $message = $hash->{message} || {};
    my $logprobs;
    if (exists $hash->{logprobs}) {
        if (ref $hash->{logprobs} eq 'HASH') {
            $logprobs = Dedalus::Types::Chat::ChoiceLogprobs->from_hash($hash->{logprobs});
        } elsif (blessed($hash->{logprobs}) && $hash->{logprobs}->isa('Dedalus::Types::Chat::ChoiceLogprobs')) {
            $logprobs = $hash->{logprobs};
        }
    }

    return $class->new(
        index         => $hash->{index} // 0,
        finish_reason => $hash->{finish_reason},
        message       => Dedalus::Types::Chat::ParsedChatCompletionMessage->from_hash($message),
        logprobs      => $logprobs,
    );
}

1;

package Dedalus::Types::Chat::ParsedChatCompletion;
use Moo;
use Types::Standard qw(Str ArrayRef Maybe InstanceOf);

use Dedalus::Types::Chat::ParsedChatCompletionMessage;
use Dedalus::Types::Chat::ParsedChoice;
use Dedalus::Types::Chat::Usage;

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has object => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'chat.completion' },
);

has model => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has created => (
    is  => 'ro',
    isa => Maybe[Str],
);

has service_tier => (
    is  => 'ro',
    isa => Maybe[Str],
);

has system_fingerprint => (
    is  => 'ro',
    isa => Maybe[Str],
);

has choices => (
    is      => 'ro',
    isa     => ArrayRef[InstanceOf['Dedalus::Types::Chat::ParsedChoice']],
    default => sub { [] },
);

has usage => (
    is      => 'ro',
    isa     => InstanceOf['Dedalus::Types::Chat::Usage'],
    default => sub { Dedalus::Types::Chat::Usage->new },
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @choices = map { Dedalus::Types::Chat::ParsedChoice->from_hash($_) } @{ $hash->{choices} || [] };
    my $usage = Dedalus::Types::Chat::Usage->from_hash($hash->{usage});

    return $class->new(
        id                 => $hash->{id},
        object             => $hash->{object} // 'chat.completion',
        model              => $hash->{model} // '',
        created            => $hash->{created},
        service_tier       => $hash->{service_tier},
        system_fingerprint => $hash->{system_fingerprint},
        choices            => \@choices,
        usage              => $usage,
    );
}

1;
