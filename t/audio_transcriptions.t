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
                text     => 'hello world',
                language => 'english',
                duration => 1.5,
                segments => [
                    {
                        id                => 0,
                        avg_logprob       => -0.5,
                        compression_ratio => 1.02,
                        end               => 1.5,
                        no_speech_prob    => 0.01,
                        seek              => 0,
                        start             => 0,
                        temperature       => 0.2,
                        text              => 'hello world',
                        tokens            => [0, 1, 2],
                    },
                ],
                words => [
                    { start => 0, end => 0.5, word => 'hello' },
                    { start => 0.5, end => 1.5, word => 'world' },
                ],
                logprobs => [
                    { token => 'hello', bytes => [104, 101, 108], logprob => -0.1 },
                ],
                usage => {
                    type         => 'tokens',
                    input_tokens => 10,
                    output_tokens => 0,
                    total_tokens => 10,
                    input_token_details => {
                        audio_tokens => 8,
                        text_tokens  => 2,
                    },
                },
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
is($resp->format, 'verbose_json', 'format inferred from verbose payload');
is($resp->language, 'english', 'language parsed');
is($resp->duration, 1.5, 'duration parsed');
is(scalar @{ $resp->segments }, 1, 'segments parsed');
isa_ok($resp->segments->[0], 'Dedalus::Types::Audio::Segment');
is($resp->segments->[0]->text, 'hello world', 'segment text preserved');
isa_ok($resp->words->[0], 'Dedalus::Types::Audio::Word');
isa_ok($resp->logprobs->[0], 'Dedalus::Types::Audio::TranscriptionLogprob');
isa_ok($resp->usage, 'Dedalus::Types::Audio::TranscriptionUsage');
is($resp->usage->input_tokens, 10, 'usage tokens parsed');

is($http->{last}{path}, '/v1/audio/transcriptions', 'hit audio endpoint');

done_testing;
