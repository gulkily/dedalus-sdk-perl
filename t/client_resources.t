use Test2::V0;
use Dedalus;

local $ENV{DEDALUS_API_KEY} = 'test-key';
my $client = Dedalus->new();

isa_ok($client->chat, 'Dedalus::Resources::Chat');
isa_ok($client->chat->completions, 'Dedalus::Resources::Chat::Completions');
isa_ok($client->models, 'Dedalus::Resources::Models');
isa_ok($client->embeddings, 'Dedalus::Resources::Embeddings');
isa_ok($client->audio, 'Dedalus::Resources::Audio');
isa_ok($client->images, 'Dedalus::Resources::Images');
isa_ok($client->files, 'Dedalus::Resources::Files');
isa_ok($client->files->content, 'Dedalus::Resources::Files::Content');
isa_ok($client->responses, 'Dedalus::Resources::Responses');
isa_ok($client->root, 'Dedalus::Resources::Root');

ok(1, 'chat resource wired');

done_testing;
