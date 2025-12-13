use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last} = { method => $method, path => $path, opts => \%opts };
        return {
            status  => 200,
            headers => { 'content-type' => 'audio/mpeg' },
            content => 'binary-data',
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $resp = $client->audio->speech->create(
    model => 'openai/tts-1',
    input => 'Hello world',
    voice => 'alloy',
);

is($resp->{content}, 'binary-data', 'returns binary data');
like($http->{last}{opts}{headers}{Accept}, qr/audio\//, 'accept header set');

like($http->{last}{opts}{json}{voice}, qr/alloy/, 'body captured');

done_testing;
