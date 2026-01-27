use Test2::V0;
use Cpanel::JSON::XS qw(encode_json);
use Test::MockModule;
use Dedalus::Async;

my $http_mock = Test::MockModule->new('Dedalus::HTTP');
$http_mock->mock('stream_request', sub {
    my ($self, $method, $path, %opts) = @_;
    my $cb = $opts{on_chunk};
    my $payload = encode_json({
        id      => 'chunk_1',
        object  => 'chat.completion.chunk',
        created => 1,
        model   => 'openai/gpt-5-nano',
        choices => [ { index => 0, delta => { content => 'Hello' } } ],
    });
    $cb->("data: $payload\n\n");
    $cb->("data: [DONE]\n\n", { Status => 200 });
    return bless({}, 'Guard');
});

my $client = Dedalus::Async->new(api_key => 'test');
my $future = $client->chat->completions->create(
    model    => 'openai/gpt-5-nano',
    messages => [ { role => 'user', content => 'Hi' } ],
    stream   => 1,
);

my $stream = $future->get;
isa_ok($stream, 'Dedalus::Stream');
my $chunk = $stream->next;
isa_ok($chunk, 'Dedalus::Types::Chat::CompletionChunk');
is($chunk->choices->[0]->delta->{content}, 'Hello', 'async stream chunk parsed');

ok(!$stream->next, 'stream drained');

done_testing;
