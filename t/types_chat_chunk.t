use Test2::V0;
use Dedalus::Types::Chat::CompletionChunk;
use Dedalus::Types::Chat::ChunkChoice;

my $raw = {
    id      => 'chunk_123',
    object  => 'chat.completion.chunk',
    created => 1,
    model   => 'openai/gpt-5-nano',
    choices => [
        {
            index => 0,
            delta => { content => 'Hello' },
        },
    ],
};

my $chunk = Dedalus::Types::Chat::CompletionChunk->from_hash($raw);
isa_ok($chunk, 'Dedalus::Types::Chat::CompletionChunk');
isa_ok($chunk->choices->[0], 'Dedalus::Types::Chat::ChunkChoice');
is($chunk->choices->[0]->delta->{content}, 'Hello', 'delta preserved');

like(dies { Dedalus::Types::Chat::CompletionChunk->from_hash({}) }, qr/id/, 'requires id');

my $choice = Dedalus::Types::Chat::ChunkChoice->from_hash({ delta => { role => 'assistant' }, index => 1 });
is($choice->index, 1, 'chunk choice index set');

like(dies { Dedalus::Types::Chat::ChunkChoice->from_hash({}) }, qr/delta/, 'delta required');

done_testing;
