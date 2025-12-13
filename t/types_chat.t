use Test2::V0;
use Dedalus::Types::Chat::Completion;

my $raw = {
    id      => 'cmpl_123',
    object  => 'chat.completion',
    model   => 'openai/gpt-5-nano',
    choices => [
        {
            index => 0,
            message => { role => 'assistant', content => 'Hello!' },
            finish_reason => 'stop',
        },
    ],
    usage => {
        prompt_tokens     => 5,
        completion_tokens => 7,
        total_tokens      => 12,
    },
};

my $completion = Dedalus::Types::Chat::Completion->from_hash($raw);
isa_ok($completion, 'Dedalus::Types::Chat::Completion');
isa_ok($completion->choices->[0], 'Dedalus::Types::Chat::Choice');
isa_ok($completion->choices->[0]->message, 'Dedalus::Types::Chat::Message');
is($completion->choices->[0]->message->content, 'Hello!', 'message content extracted');

is($completion->usage->total_tokens, 12, 'usage parsed');

done_testing;
