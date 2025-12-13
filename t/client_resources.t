use Test2::V0;
use Dedalus;

local $ENV{DEDALUS_API_KEY} = 'test-key';
my $client = Dedalus->new();

isa_ok($client->chat, 'Dedalus::Resources::Chat');
isa_ok($client->chat->completions, 'Dedalus::Resources::Chat::Completions');
isa_ok($client->models, 'Dedalus::Resources::Models');
isa_ok($client->embeddings, 'Dedalus::Resources::Embeddings');

ok(1, 'chat resource wired');

done_testing;
