use Test2::V0;

use Dedalus::Config;
use Dedalus::HTTP;
use Dedalus::Util::QS qw(stringify);

my $config = Dedalus::Config->new(
    api_key  => 'test',
    base_url => 'https://api.test/v1/',
);
my $http = Dedalus::HTTP->new(config => $config);

my $url = $http->_build_url('/models', { foo => 'bar' });
is($url, 'https://api.test/v1/models?foo=bar', 'build_url joins base and path');

my $expected_qs = stringify({
    filter => { role => 'user' },
    ids    => [1, 2],
});
my $url2 = $http->_build_url('chat/completions', {
    filter => { role => 'user' },
    ids    => [1, 2],
});
is($url2, "https://api.test/v1/chat/completions?$expected_qs", 'build_url encodes nested/array query');

done_testing;
