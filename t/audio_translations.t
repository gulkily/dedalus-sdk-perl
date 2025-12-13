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
            data   => { text => 'hello', raw => {} },
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

done_testing;
