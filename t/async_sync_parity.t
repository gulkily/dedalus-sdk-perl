use Test2::V0;
use Test::MockModule;
use Future;
use AnyEvent;

use Dedalus;
use Dedalus::Async;

{
    package CaptureHTTP;
    sub new { bless { calls => [] }, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        push @{ $self->{calls} }, { method => $method, path => $path, opts => \%opts };
        return {
            status => 200,
            headers => {},
            data => { object => 'ok' },
        };
    }
    sub calls { shift->{calls} }
}

my $http = CaptureHTTP->new;
my $client = Dedalus::Client->new(api_key => 'sk-test', http => $http);

$client->embeddings->create(
    model => 'text-embedding-3-small',
    input => [ 'foo', 'bar' ],
    user  => 'perl-sdk',
);

my $last_call = $http->calls->[-1];
is($last_call->{method}, 'POST', 'sync method used POST');
is($last_call->{path}, '/v1/embeddings', 'sync target path');
my $sync_body = $last_call->{opts}{json};

my $async = Dedalus::Async->new(api_key => 'sk-test');

my @async_calls;
my $mock = Test::MockModule->new('Dedalus::Async::Client');
$mock->redefine('request_future', sub {
    my ($self, $method, $path, %opts) = @_;
    push @async_calls, { method => $method, path => $path, opts => \%opts };
    return Future->done({ status => 200, headers => {}, data => {} });
});

my $future = $async->embeddings->create(
    model => 'text-embedding-3-small',
    input => [ 'foo', 'bar' ],
    user  => 'perl-sdk',
);
$future->get;

my $async_call = $async_calls[-1];
is($async_call->{method}, 'POST', 'async method matches');
is($async_call->{path}, '/v1/embeddings', 'async path matches');
my $async_body = $async_call->{opts}{json};

is($async_body, $sync_body, 'async and sync serialization match');

# Streaming fixture parity: ensure chat stream uses same payload shape
my $stream_mock = Test::MockModule->new('Dedalus::HTTP');
$stream_mock->redefine('stream_request', sub {
    my ($self, $method, $path, %opts) = @_;
    is($method, 'POST', 'streaming uses POST');
    is($path, '/v1/chat/completions', 'streaming path matches');
    like($opts{json}{messages}[0]{role}, qr/system|user/, 'stream payload contains messages');
    my $on_chunk = $opts{on_chunk};
    $on_chunk->('data: {"id":"1"}\n\n');
    $on_chunk->(undef, { Status => 200 });
    return AnyEvent->condvar;
});

my $stream_client = Dedalus->new(api_key => 'sk-test');
$stream_client->chat->completions->create(
    model => 'openai/gpt-5-nano',
    messages => [ { role => 'user', content => 'ping' } ],
    stream => 1,
);

$mock->unmock_all;
$stream_mock->unmock_all;

done_testing;
