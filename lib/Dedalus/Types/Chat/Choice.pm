package Dedalus::Types::Chat::Choice;
use Moo;
use Scalar::Util qw(blessed);
use Types::Standard qw(Int Maybe Str InstanceOf);
use Dedalus::Types::Chat::Message;
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
    isa      => InstanceOf['Dedalus::Types::Chat::Message'],
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
        message       => Dedalus::Types::Chat::Message->from_hash($message),
        logprobs      => $logprobs,
    );
}

1;
