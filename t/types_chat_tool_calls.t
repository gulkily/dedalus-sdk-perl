use Test2::V0;
use Dedalus::Types::Chat::Message;

my $raw = {
    role => 'assistant',
    content => 'Calling tool',
    tool_calls => [
        {
            type => 'function',
            id   => 'call_123',
            function => {
                name      => 'get_weather',
                arguments => '{"location":"Paris"}'
            },
        },
    ],
};

my $message = Dedalus::Types::Chat::Message->from_hash($raw);
isa_ok($message->tool_calls->[0], 'Dedalus::Types::Chat::ToolCall');
is($message->tool_calls->[0]->function->{name}, 'get_weather', 'tool call parsed');

like(dies { Dedalus::Types::Chat::ToolCall->from_hash('bad') }, qr/hash/, 'tool call validation');

done_testing;
