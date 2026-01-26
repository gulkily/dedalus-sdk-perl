use Test2::V0;
use Cpanel::JSON::XS qw(encode_json);
use Test::MockModule;
use Dedalus;

my $http_mock = Test::MockModule->new('Dedalus::HTTP');
my $call_count = 0;
$http_mock->mock('stream_request', sub {
    my ($self, $method, $path, %opts) = @_;
    $call_count++;
    my $cb = $opts{on_chunk};

    if ($call_count == 1) {
        my $payload = encode_json({
            id      => 'chunk_1',
            object  => 'chat.completion.chunk',
            created => 1,
            model   => 'openai/gpt-5-nano',
            choices => [
                {
                    index => 0,
                    delta => {
                        tool_calls => [
                            {
                                index    => 0,
                                id       => 'call_1',
                                type     => 'function',
                                function => {
                                    name      => 'get_weather',
                                    arguments => '{"location":"Boston"}',
                                },
                            },
                        ],
                    },
                },
            ],
        });
        $cb->("data: $payload\n\n");
        $cb->("data: [DONE]\n\n", { Status => 200 });
        return bless({}, 'Guard');
    }

    my $payload = encode_json({
        id      => 'chunk_2',
        object  => 'chat.completion.chunk',
        created => 2,
        model   => 'openai/gpt-5-nano',
        choices => [
            { index => 0, delta => { content => 'Done' } },
        ],
    });
    $cb->("data: $payload\n\n");
    $cb->("data: [DONE]\n\n", { Status => 200 });
    return bless({}, 'Guard');
});

my $client = Dedalus->new(api_key => 'test');
my $stream = $client->runner->run(
    model  => 'openai/gpt-5-nano',
    input  => 'Weather?',
    stream => 1,
    tools  => [
        {
            name       => 'get_weather',
            parameters => {
                type       => 'object',
                properties => { location => { type => 'string' } },
                required   => ['location'],
            },
            handler => sub {
                my (%args) = @_;
                return "sunny in $args{location}";
            },
        },
    ],
);

isa_ok($stream, 'Dedalus::Stream');
my $first = $stream->next;
isa_ok($first, 'Dedalus::Types::Chat::CompletionChunk');
my $second = $stream->next;
isa_ok($second, 'Dedalus::Types::Chat::CompletionChunk');
ok(!$stream->next, 'stream drained');
is($call_count, 2, 'runner performed two streaming calls');

my $result = $stream->result;
isa_ok($result, 'Dedalus::Types::Runner::RunResult');
is($result->final_output, 'Done', 'final output captured');
is(scalar @{ $result->tool_results }, 1, 'tool result captured');

done_testing;
