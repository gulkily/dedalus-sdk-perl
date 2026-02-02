use Test2::V0;

use Dedalus::HTTP;
use Dedalus::Config;

my $config = Dedalus::Config->new(api_key => 'test');
my $http = Dedalus::HTTP->new(config => $config);

ok($http->_should_retry(undef), 'retry on undef status');
ok($http->_should_retry(0), 'retry on 0 status');
ok($http->_should_retry(408), 'retry on 408');
ok($http->_should_retry(409), 'retry on 409');
ok($http->_should_retry(429), 'retry on 429');
ok($http->_should_retry(500), 'retry on 500');
ok($http->_should_retry(503), 'retry on 503');

ok(!$http->_should_retry(200), 'no retry on 200');
ok(!$http->_should_retry(404), 'no retry on 404');

done_testing;
