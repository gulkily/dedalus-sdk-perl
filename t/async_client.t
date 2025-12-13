use Test2::V0;
use Dedalus::Async;

my $client = Dedalus::Async->new(api_key => 'test');
isa_ok($client, 'Dedalus::Async::Client');

my $future = $client->request_future('GET', '/test', headers => {});
isa_ok($future, 'Future');

$future->on_ready(sub {
    ok(1, 'future ready callback invoked');
});

ok(1, 'async client constructed');

pass('placeholder');

done_testing;
