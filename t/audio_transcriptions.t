use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last} = { method => $method, path => $path, opts => \%opts };
        return {
            status => 200,
            data   => {
                text => 'hello world',
            },
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $audio = "test";
my $resp = $client->audio->transcriptions->create(
    model => 'openai/whisper-1',
    file  => \$audio,
);

isa_ok($resp, 'Dedalus::Types::Audio::TranscriptionCreateResponse');
isa_ok($client->audio->transcriptions, 'Dedalus::Resources::Audio::Transcriptions');

is($resp->text, 'hello world', 'transcription text returned');

is($http->{last}{path}, '/v1/audio/transcriptions', 'hit audio endpoint');

done_testing;
