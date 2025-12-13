use Test2::V0;
use Cpanel::JSON::XS qw(encode_json);
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last} = { method => $method, path => $path, opts => \%opts };
        my $payload = Cpanel::JSON::XS::encode_json({ choices => [ { delta => { content => 'Hello' } } ] });
        my $chunks = join("\n\n",
            "data: $payload",
            "data: [DONE]",
            ''
        );
        return {
            status  => 200,
            headers => { 'content-type' => 'text/event-stream' },
            content => $chunks,
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $stream = $client->chat->completions->create(
    model    => 'openai/gpt-5-nano',
    messages => [ { role => 'user', content => 'Hi' } ],
    stream   => 1,
);

isa_ok($stream, 'Dedalus::Stream');
my $chunk = $stream->next;
is($chunk->{choices}[0]{delta}{content}, 'Hello', 'stream chunk parsed');

ok(!$stream->next, 'stream drained');
like($http->{last}{opts}{json}{stream}, qr/1/, 'stream param sent');

done_testing;
