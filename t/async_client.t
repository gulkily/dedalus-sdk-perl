use Test2::V0;
use Future;
use Test::MockModule;

use Dedalus::Async;

my $client = Dedalus::Async->new(api_key => 'test');
isa_ok($client, 'Dedalus::Async::Client');
isa_ok($client->chat, 'Dedalus::Async::Chat');
isa_ok($client->audio, 'Dedalus::Async::Audio');
isa_ok($client->embeddings, 'Dedalus::Async::Embeddings');
isa_ok($client->images, 'Dedalus::Async::Images');
isa_ok($client->models, 'Dedalus::Async::Models');
isa_ok($client->health, 'Dedalus::Async::Health');
isa_ok($client->files, 'Dedalus::Async::Files');
isa_ok($client->files->content, 'Dedalus::Async::Files::Content');

my $mock = Test::MockModule->new('Dedalus::Async::Client');
$mock->redefine('request_future', sub {
    my ($self, $method, $path, %opts) = @_;
    if ($path eq '/v1/chat/completions') {
        return Future->done({
            status => 200,
            headers => {},
            data => {
                id => 'cmpl_123',
                object => 'chat.completion',
                model => 'openai/gpt-5-nano',
                choices => [],
            },
        });
    }
    if ($path eq '/v1/audio/transcriptions') {
        return Future->done({ status => 200, headers => {}, data => { text => 'hello' } });
    }
    if ($path eq '/v1/audio/translations') {
        return Future->done({ status => 200, headers => {}, data => { text => 'hola', raw => {} } });
    }
    if ($path eq '/v1/audio/speech') {
        return Future->done({ status => 200, headers => {}, content => 'mp3data' });
    }
    if ($path eq '/v1/embeddings') {
        return Future->done({ status => 200, headers => {}, data => { data => [ { embedding => [0.1], index => 0 } ], model => 'text-embedding-3-small', usage => {} } });
    }
    if ($path =~ /\/v1\/images\//) {
        return Future->done({ status => 200, headers => {}, data => { created => 123, data => [ { url => 'https://example' } ] } });
    }
    if ($path eq '/v1/models' && $method eq 'GET') {
        return Future->done({ status => 200, headers => {}, data => { object => 'list', data => [ { id => 'm1', object => 'model', owned_by => 'openai' } ] } });
    }
    if ($path eq '/v1/models/m1' && $method eq 'GET') {
        return Future->done({ status => 200, headers => {}, data => { id => 'm1', object => 'model', owned_by => 'openai' } });
    }
    if ($path eq '/health') {
        return Future->done({ status => 200, headers => {}, data => { status => 'ok' } });
    }
    if ($path eq '/v1/files' && $method eq 'GET') {
        return Future->done({ status => 200, headers => {}, data => { object => 'list', data => [ { id => 'file-1', object => 'file', filename => 'example.txt' } ] } });
    }
    if ($path eq '/v1/files' && $method eq 'POST') {
        return Future->done({ status => 200, headers => {}, data => { id => 'file-2', object => 'file', filename => 'upload.dat' } });
    }
    if ($path eq '/v1/files/file-1' && $method eq 'GET') {
        return Future->done({ status => 200, headers => {}, data => { id => 'file-1', object => 'file', filename => 'example.txt' } });
    }
    if ($path eq '/v1/files/file-1' && $method eq 'DELETE') {
        return Future->done({ status => 200, headers => {}, data => { id => 'file-1', deleted => 1 } });
    }
    if ($path eq '/v1/files/file-1/content' && $method eq 'GET') {
        return Future->done({ status => 200, headers => {}, content => 'hello-bytes' });
    }
    die "unexpected path $path";
});

my $chat_future = $client->chat->completions->create(
    model    => 'openai/gpt-5-nano',
    messages => [ { role => 'user', content => 'Hi' } ],
);
isa_ok($chat_future, 'Future');
my $completion = $chat_future->get;
isa_ok($completion, 'Dedalus::Types::Chat::Completion');

my $audio_blob = 'data';
my $audio_future = $client->audio->transcriptions->create(
    model => 'openai/whisper-1',
    file  => \$audio_blob,
);
isa_ok($audio_future->get, 'Dedalus::Types::Audio::TranscriptionCreateResponse');

my $trans_future = $client->audio->translations->create(
    model => 'openai/whisper-1',
    file  => \$audio_blob,
);
isa_ok($trans_future->get, 'Dedalus::Types::Audio::TranslationCreateResponse');

my $speech_future = $client->audio->speech->create(
    model => 'openai/tts-1',
    input => 'Hello world',
    voice => 'alloy',
);
my $speech = $speech_future->get;
is($speech->{content}, 'mp3data', 'speech future returns payload');

my $embed_future = $client->embeddings->create(
    model => 'text-embedding-3-small',
    input => 'hello',
);
isa_ok($embed_future->get, 'Dedalus::Types::CreateEmbeddingResponse');

my $image_future = $client->images->generate(prompt => 'A cat');
isa_ok($image_future->get, 'Dedalus::Types::ImagesResponse');

my $models_future = $client->models->list;
isa_ok($models_future->get, 'Dedalus::Types::ListModelsResponse');

my $model_future = $client->models->retrieve('m1');
isa_ok($model_future->get, 'Dedalus::Types::Model');

my $health_future = $client->health->check;
isa_ok($health_future->get, 'Dedalus::Types::HealthCheckResponse');

my $files_list_future = $client->files->list;
isa_ok($files_list_future->get, 'Dedalus::Types::ListFilesResponse');

my $file_future = $client->files->retrieve('file-1');
isa_ok($file_future->get, 'Dedalus::Types::FileObject');

my $upload_future = $client->files->upload(purpose => 'fine-tune', file => \"hello");
isa_ok($upload_future->get, 'Dedalus::Types::FileObject');

my $delete_future = $client->files->delete('file-1');
is($delete_future->get->{deleted}, 1, 'delete future returns hash');

my $content_future = $client->files->content->retrieve('file-1');
is($content_future->get->{content}, 'hello-bytes', 'content future returns payload');

done_testing;
