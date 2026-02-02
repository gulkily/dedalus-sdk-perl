use Test2::V0;
use Dedalus::Types::Chat::ParsedChatCompletion;

my $raw = {
    id      => 'cmpl_parsed',
    object  => 'chat.completion',
    model   => 'openai/gpt-5-nano',
    choices => [
        {
            index => 0,
            message => {
                role    => 'assistant',
                content => '{"answer":"ok"}',
                parsed  => { answer => 'ok' },
                tool_calls => [
                    {
                        id   => 'call_1',
                        type => 'function',
                        function => {
                            name             => 'get_weather',
                            arguments        => '{"location":"Boston"}',
                            parsed_arguments => { location => 'Boston' },
                        },
                    },
                ],
            },
            finish_reason => 'stop',
        },
    ],
    usage => {
        prompt_tokens     => 1,
        completion_tokens => 1,
        total_tokens      => 2,
    },
};

my $parsed = Dedalus::Types::Chat::ParsedChatCompletion->from_hash($raw);
isa_ok($parsed, 'Dedalus::Types::Chat::ParsedChatCompletion');
isa_ok($parsed->choices->[0], 'Dedalus::Types::Chat::ParsedChoice');
isa_ok($parsed->choices->[0]->message, 'Dedalus::Types::Chat::ParsedChatCompletionMessage');
isa_ok($parsed->choices->[0]->message->tool_calls->[0], 'Dedalus::Types::Chat::ParsedFunctionToolCall');
isa_ok($parsed->choices->[0]->message->tool_calls->[0]->function, 'Dedalus::Types::Chat::ParsedFunction');

is($parsed->choices->[0]->message->parsed->{answer}, 'ok', 'parsed content retained');
is($parsed->choices->[0]->message->tool_calls->[0]->function->parsed_arguments->{location}, 'Boston', 'parsed args retained');

done_testing;
