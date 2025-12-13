use Test2::V0;

local $ENV{DEDALUS_API_KEY} = 'test-key';

use_ok('Dedalus');
use_ok('Dedalus::Client');
use_ok('Dedalus::Config');
use_ok('Dedalus::Types::HealthCheckResponse');

my $client = Dedalus->new(environment => 'development');
isa_ok($client, 'Dedalus::Client');

is($client->config->environment, 'development', 'environment propagated');
like($client->headers->{Authorization}, qr/test-key/, 'api key used in headers');

ok(1, 'placeholder');

done_testing;
