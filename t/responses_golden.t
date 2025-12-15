use Test2::V0;
use Cpanel::JSON::XS qw(decode_json);
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last_request} = { method => $method, path => $path, json => $opts{json} };
        return { status => 200, data => { id => 'resp', object => 'response', model => $opts{json}{model}, output => [] } };
    }
}

my $fixture = do {
    local $/;
    open my $fh, '<', 't/fixtures/responses_request.json' or die $!;
    decode_json(<$fh>);
};

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

$client->responses->create(%$fixture);

is($http->{last_request}{path}, '/v1/responses', 'hits responses path');
my $body = $http->{last_request}{json};
is($body->{model}, $fixture->{model}, 'model matches fixture');
is($body->{input}, $fixture->{input}, 'input matches fixture');
is($body->{metadata}{purpose}, 'golden-test', 'metadata preserved');

done_testing;
