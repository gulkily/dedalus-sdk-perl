use Test2::V0;
use Dedalus::Types::CreateEmbeddingResponse;

my $raw = {
    object => 'list',
    model  => 'text-embedding-3-small',
    usage  => { prompt_tokens => 2, total_tokens => 2 },
    data   => [
        {
            object    => 'embedding',
            index     => 0,
            embedding => [0.1, 0.2],
        },
    ],
};

my $resp = Dedalus::Types::CreateEmbeddingResponse->from_hash($raw);
isa_ok($resp, 'Dedalus::Types::CreateEmbeddingResponse');
isa_ok($resp->data->[0], 'Dedalus::Types::Embeddings::Data');

done_testing;
