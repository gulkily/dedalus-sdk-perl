use Test2::V0;
use Future;
use Test::MockModule;

use Dedalus::Async;

my $client = Dedalus::Async->new(api_key => 'test');
isa_ok($client, 'Dedalus::Async::Client');
isa_ok($client->chat, 'Dedalus::Async::Chat');
isa_ok($client->audio, 'Dedalus::Async::Audio');

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

done_testing;
