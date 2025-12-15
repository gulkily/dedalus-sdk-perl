package Dedalus::Types::Chat::Message;
use Moo;
use Types::Standard qw(Str Any ArrayRef Maybe InstanceOf);
use Dedalus::Types::Chat::ToolCall;

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

has tool_calls => (
    is  => 'ro',
    isa => Maybe[ArrayRef[InstanceOf['Dedalus::Types::Chat::ToolCall']]],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $tool_calls;
    if (exists $hash->{tool_calls} && ref $hash->{tool_calls} eq 'ARRAY') {
        my @calls = map { Dedalus::Types::Chat::ToolCall->from_hash($_) } @{ $hash->{tool_calls} };
        $tool_calls = \@calls;
    }
    return $class->new(
      role    => $hash->{role} // 'assistant',
      content => $hash->{content},
      tool_calls => $tool_calls,
    );
}

1;
