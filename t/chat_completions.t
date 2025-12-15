use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last_request} = {
            method => $method,
            path   => $path,
            opts   => \%opts,
        };
        return {
            status  => 200,
            headers => { 'content-type' => 'application/json' },
            data    => {
                id      => 'cmpl_test',
                object  => 'chat.completion',
                model   => $opts{json}{model},
                choices => [
                    {
                        index   => 0,
                        message => {
                            role       => 'assistant',
                            content    => 'Hello!',
                            tool_calls => [
                                {
                                    type => 'function',
                                    id   => 'call_1',
                                    function => { name => 'get_weather', arguments => '{"location":"Paris"}' },
                                },
                            ],
                        },
                        finish_reason => 'stop',
                    }
                ],
                usage => { total_tokens => 12 },
            },
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(
    api_key => 'test-key',
    http    => $http,
);

my $completion = $client->chat->completions->create(
    model    => 'openai/gpt-5-nano',
    messages => [ { role => 'user', content => 'Hi!' } ],
);

isa_ok($completion, 'Dedalus::Types::Chat::Completion');
isa_ok($completion->choices->[0], 'Dedalus::Types::Chat::Choice');
is($completion->choices->[0]->message->content, 'Hello!', 'returns parsed assistant text');
isa_ok($completion->choices->[0]->message->tool_calls->[0], 'Dedalus::Types::Chat::ToolCall');

is(
    $http->{last_request}{path},
    '/v1/chat/completions',
    'hits chat endpoint',
);

is($http->{last_request}{opts}{json}{messages}[0]{content}, 'Hi!', 'sends user message');

done_testing;
