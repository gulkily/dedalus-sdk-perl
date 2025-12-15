use Test2::V0;
use Cpanel::JSON::XS qw(decode_json encode_json);
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last_request} = { method => $method, path => $path, body => $opts{json} };
        return { status => 200, data => { id => 'cmpl', object => 'chat.completion', model => $opts{json}{model}, choices => [] } };
    }
}

my $expected = do {
    local $/;
    open my $fh, '<', 't/fixtures/chat_completion_request.json' or die $!;
    decode_json(<$fh>);
};

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

$client->chat->completions->create(%$expected);

is($http->{last_request}{path}, '/v1/chat/completions', 'hits endpoint');
my $body = $http->{last_request}{body};

is($body->{model}, $expected->{model}, 'model matches fixture');

is($body->{messages}, $expected->{messages}, 'messages match fixture');

ok($body->{temperature} == 0.2, 'temperature preserved');

done_testing;
