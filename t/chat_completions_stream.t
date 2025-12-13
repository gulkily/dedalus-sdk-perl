use Test2::V0;
use Cpanel::JSON::XS qw(encode_json);
use Test::MockModule;
use Dedalus;

my $http_mock = Test::MockModule->new('Dedalus::HTTP');
$http_mock->mock('stream_request', sub {
    my ($self, $method, $path, %opts) = @_;
    my $cb = $opts{on_chunk};
    my $payload = encode_json({ choices => [ { delta => { content => 'Hello' } } ] });
    $cb->("data: $payload\n\n");
    $cb->("data: [DONE]\n\n", { Status => 200 });
    return bless({}, 'Guard');
});

$http_mock->mock('request', sub {
    my ($self, $method, $path, %opts) = @_;
    return {
        status  => 200,
        headers => {},
        content => '',
    };
});

my $client = Dedalus->new(api_key => 'test');

my $stream = $client->chat->completions->create(
    model    => 'openai/gpt-5-nano',
    messages => [ { role => 'user', content => 'Hi' } ],
    stream   => 1,
);

isa_ok($stream, 'Dedalus::Stream');
my $chunk = $stream->next;
is($chunk->{choices}[0]{delta}{content}, 'Hello', 'stream chunk parsed');

ok(!$stream->next, 'stream drained');

done_testing;
