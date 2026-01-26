use Test2::V0;
use Dedalus::Types::Chat::ChunkChoice;
use Dedalus::Types::Chat::Usage;

my $choice = Dedalus::Types::Chat::ChunkChoice->from_hash({
    delta => { content => 'hi' },
    index => 0,
    logprobs => {
        content => [
            {
                token        => 'hi',
                logprob      => -0.1,
                top_logprobs => [ { token => 'hi', logprob => -0.1 } ],
            },
        ],
    },
});

isa_ok($choice->logprobs, 'Dedalus::Types::Chat::ChunkLogprobs');
isa_ok($choice->logprobs->content->[0], 'Dedalus::Types::Chat::CompletionTokenLogprob');
isa_ok($choice->logprobs->content->[0]->top_logprobs->[0], 'Dedalus::Types::Chat::TopLogprob');

my $usage = Dedalus::Types::Chat::Usage->from_hash({
    prompt_tokens => 2,
    completion_tokens => 3,
    total_tokens => 5,
    completion_tokens_details => {
        reasoning_tokens => 1,
    },
    prompt_tokens_details => {
        cached_tokens => 2,
    },
});

isa_ok($usage->completion_tokens_details, 'Dedalus::Types::Chat::UsageCompletionTokensDetails');
is($usage->completion_tokens_details->reasoning_tokens, 1, 'completion details parsed');
isa_ok($usage->prompt_tokens_details, 'Dedalus::Types::Chat::UsagePromptTokensDetails');
is($usage->prompt_tokens_details->cached_tokens, 2, 'prompt details parsed');

done_testing;
