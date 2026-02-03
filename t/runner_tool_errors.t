use Test2::V0;
use Dedalus::Runner;
use Dedalus::Types::Chat::Completion;

{
    package TestCompletions;
    sub new {
        my ($class, $responses) = @_;
        return bless { responses => $responses, seen => [] }, $class;
    }
    sub create {
        my ($self, %params) = @_;
        push @{ $self->{seen} }, \%params;
        return shift @{ $self->{responses} };
    }
}

{
    package TestChat;
    sub new { bless { completions => $_[1] }, shift }
    sub completions { return shift->{completions} }
}

{
    package TestClient;
    sub new {
        my ($class, $responses) = @_;
        my $completions = TestCompletions->new($responses);
        my $chat = TestChat->new($completions);
        return bless { chat => $chat }, $class;
    }
    sub chat { return shift->{chat} }
}

my $first = Dedalus::Types::Chat::Completion->from_hash({
    id      => 'c1',
    model   => 'm',
    choices => [
        {
            message => {
                role       => 'assistant',
                content    => undef,
                tool_calls => [
                    {
                        id       => 'call_1',
                        type     => 'function',
                        function => {
                            name      => 'explode',
                            arguments => '{}',
                        },
                    },
                    {
                        id       => 'call_2',
                        type     => 'function',
                        function => {
                            name      => 'missing',
                            arguments => '{}',
                        },
                    },
                ],
            },
        },
    ],
});

my $second = Dedalus::Types::Chat::Completion->from_hash({
    id      => 'c2',
    model   => 'm',
    choices => [
        {
            message => {
                role    => 'assistant',
                content => 'done',
            },
        },
    ],
});

my $client = TestClient->new([ $first, $second ]);
my $runner = Dedalus::Runner->new(client => $client);

my $result = $runner->run(
    model => 'm',
    input => 'hi',
    max_steps => 3,
    tools => [
        {
            name       => 'explode',
            parameters => { type => 'object', properties => {}, required => [] },
            handler    => sub { die "boom\n"; },
        },
    ],
);

is(scalar @{ $result->tool_results }, 2, 'captures both tool results');
like($result->tool_results->[0]->error, qr/boom/, 'captures tool error');
is($result->tool_results->[1]->error, "tool 'missing' not found", 'missing tool error');
is($result->final_output, 'done', 'continues to final response');

done_testing;
