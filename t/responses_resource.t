use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        if ($method eq 'POST') {
            return {
                status => 200,
                data   => {
                    id     => 'resp_123',
                    object => 'response',
                    model  => $opts{json}{model},
                    status => 'in_progress',
                    output => [],
                },
            };
        }
        return {
            status => 200,
            data   => {
                id     => 'resp_123',
                object => 'response',
                model  => 'gpt-4',
                status => 'completed',
                output => [ { type => 'message', content => 'hi' } ],
            },
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $resp = $client->responses->create(
    model => 'gpt-4',
    input => [ { role => 'user', content => 'Hi' } ],
);
isa_ok($resp, 'Dedalus::Types::Response');

my $retrieved = $client->responses->retrieve('resp_123');
isa_ok($retrieved, 'Dedalus::Types::Response');

is($retrieved->output->[0]{content}, 'hi', 'output parsed');

done_testing;
