use Test2::V0;
use Dedalus::Types::Response;

my $raw = {
    id      => 'resp_123',
    object  => 'response',
    model   => 'openai/gpt-4o-mini',
    status  => 'completed',
    output  => [
        {
            type => 'message',
            role => 'assistant',
            content => [
                { type => 'text', text => 'Hello from responses' },
            ],
        },
    ],
};

my $resp = Dedalus::Types::Response->from_hash($raw);
isa_ok($resp, 'Dedalus::Types::Response');
isa_ok($resp->output->[0], 'Dedalus::Types::Response::OutputItem');
isa_ok($resp->output->[0]->content->[0], 'Dedalus::Types::Response::OutputContentBlock');
is($resp->output->[0]->content->[0]->text, 'Hello from responses', 'content parsed');

like(dies { Dedalus::Types::Response->from_hash({}) }, qr/id/, 'response requires id');

my $item = Dedalus::Types::Response::OutputItem->from_hash({ type => 'message', content => [] });
is($item->type, 'message', 'item type defaulted');

like(dies { Dedalus::Types::Response::OutputContentBlock->from_hash('bad') }, qr/hash/, 'content block validation');

done_testing;
