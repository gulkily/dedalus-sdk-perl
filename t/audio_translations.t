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
                text     => 'hello',
                language => 'english',
                duration => 2.1,
                segments => [
                    {
                        id                => 0,
                        avg_logprob       => -0.2,
                        compression_ratio => 1.01,
                        end               => 2.1,
                        no_speech_prob    => 0.05,
                        seek              => 0,
                        start             => 0,
                        temperature       => 0.4,
                        text              => 'hello',
                        tokens            => [1, 2],
                    },
                ],
            },
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $audio = "data";
my $resp = $client->audio->translations->create(
    model => 'openai/whisper-1',
    file  => \$audio,
);

isa_ok($resp, 'Dedalus::Types::Audio::TranslationCreateResponse');
like($http->{last}{opts}{headers}{'Content-Type'}, qr{multipart/form-data}, 'multipart header set');

ok(defined $resp->text, 'translation parsed');
is($resp->format, 'verbose_json', 'format inferred');
is(scalar @{ $resp->segments }, 1, 'segments parsed for translation');

done_testing;
