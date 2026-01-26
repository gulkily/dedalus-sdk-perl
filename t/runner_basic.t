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
        return bless { chat => $chat, completions => $completions }, $class;
    }
    sub chat { return shift->{chat} }
    sub completions { return shift->{completions} }
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
                            name      => 'add',
                            arguments => '{"a":1,"b":2}',
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
            name       => 'add',
            parameters => {
                type       => 'object',
                properties => { a => { type => 'integer' }, b => { type => 'integer' } },
                required   => [ 'a', 'b' ],
            },
            handler => sub {
                my (%args) = @_;
                return ($args{a} // 0) + ($args{b} // 0);
            },
        },
    ],
);

isa_ok($result, 'Dedalus::Types::Runner::RunResult');
is($result->final_output, 'done', 'final output set');
is($result->steps_used, 2, 'steps used tracks tool call + final');
is(scalar @{ $result->tool_results }, 1, 'tool results captured');
is($result->tool_results->[0]->result, 3, 'tool result stored');
is(scalar @{ $result->messages }, 4, 'messages include tool loop');

my $seen = $client->completions->{seen}[0];
ok($seen->{tools} && ref $seen->{tools} eq 'ARRAY', 'tools schema sent to completion');

done_testing;
