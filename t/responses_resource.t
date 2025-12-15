use Test2::V0;
use Cpanel::JSON::XS qw(encode_json);
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

    sub stream_request {
        my ($self, $method, $path, %opts) = @_;
        my $cb = $opts{on_chunk};
        my $payload = Cpanel::JSON::XS::encode_json({
            type  => 'content.delta',
            delta => { text => 'partial ' },
        });
        $cb->("data: $payload\n\n");
        my $done_payload = Cpanel::JSON::XS::encode_json({ type => 'content.delta', delta => { text => 'done' } });
        $cb->("data: $done_payload\n\n");
        $cb->("data: [DONE]\n\n", { Status => 200 });
        return bless {}, 'Guard';
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

my $stream = $client->responses->create(
    model  => 'gpt-4',
    input  => [ { role => 'user', content => 'Stream me' } ],
    stream => 1,
);
isa_ok($stream, 'Dedalus::Stream');
my $event = $stream->next;
isa_ok($event, 'Dedalus::Types::Response::StreamEvent');
is($event->delta->{text}, 'partial ', 'stream event delta parsed');

done_testing;
