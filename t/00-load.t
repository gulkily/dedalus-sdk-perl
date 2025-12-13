use Test2::V0;
use Dedalus;
use Dedalus::Client;
use Dedalus::Config;
use Dedalus::Types::HealthCheckResponse;

local $ENV{DEDALUS_API_KEY} = 'test-key';

my $client = Dedalus->new(environment => 'development');
isa_ok($client, 'Dedalus::Client');

is($client->config->environment, 'development', 'environment propagated');
like($client->headers->{Authorization}, qr/test-key/, 'api key used in headers');

ok(1, 'placeholder');

done_testing;
