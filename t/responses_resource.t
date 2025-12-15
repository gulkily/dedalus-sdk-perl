use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last_request} = { method => $method, path => $path, opts => \%opts };
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
                output => [ { type => 'message', content => [ { type => 'text', text => 'hi' } ] } ],
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
is($http->{last_request}{opts}{json}{input}, [ { role => 'user', content => 'Hi' } ], 'input preserved as array');

my $retrieved = $client->responses->retrieve('resp_123');
isa_ok($retrieved, 'Dedalus::Types::Response');

is($retrieved->output->[0]->content->[0]->text, 'hi', 'output parsed');

done_testing;
