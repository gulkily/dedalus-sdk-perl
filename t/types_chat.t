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
            logprobs => {
                content => [
                    {
                        token        => 'Hello',
                        logprob      => -0.2,
                        top_logprobs => [ { token => 'Hello', logprob => -0.2 } ],
                    },
                ],
            },
        },
    ],
    service_tier => 'default',
    system_fingerprint => 'fp_123',
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

isa_ok($completion->choices->[0]->logprobs, 'Dedalus::Types::Chat::ChoiceLogprobs');
is($completion->service_tier, 'default', 'service tier parsed');
is($completion->system_fingerprint, 'fp_123', 'system fingerprint parsed');
is($completion->usage->total_tokens, 12, 'usage parsed');

my $raw_audio = {
    id      => 'cmpl_audio',
    object  => 'chat.completion',
    model   => 'openai/gpt-4o-audio',
    choices => [
        {
            index => 0,
            message => {
                role    => 'assistant',
                content => undef,
                refusal => undef,
                audio   => {
                    id         => 'aud_123',
                    expires_at => 123,
                    data       => 'base64-audio',
                    transcript => 'hello audio',
                },
                annotations => [
                    {
                        type => 'url_citation',
                        url_citation => {
                            start_index => 0,
                            end_index   => 5,
                            title       => 'Example',
                            url         => 'https://example.com',
                        },
                    },
                ],
            },
            finish_reason => 'stop',
        },
    ],
    usage => {
        prompt_tokens     => 1,
        completion_tokens => 2,
        total_tokens      => 3,
    },
};

my $completion_audio = Dedalus::Types::Chat::Completion->from_hash($raw_audio);
isa_ok($completion_audio->choices->[0]->message->audio, 'Dedalus::Types::Chat::Audio');
is($completion_audio->choices->[0]->message->audio->transcript, 'hello audio', 'audio transcript parsed');
isa_ok($completion_audio->choices->[0]->message->annotations->[0], 'Dedalus::Types::Chat::Annotation');
is(
    $completion_audio->choices->[0]->message->annotations->[0]->url_citation->url,
    'https://example.com',
    'annotation citation parsed'
);

done_testing;
