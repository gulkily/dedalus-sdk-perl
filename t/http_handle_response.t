use Test2::V0;

use Dedalus::HTTP;
use Dedalus::Config;

my $http = Dedalus::HTTP->new(config => Dedalus::Config->new(api_key => 'test'));

my $resp = $http->_handle_response(
    {
        success => 1,
        status  => 200,
        headers => { 'content-type' => 'application/json' },
        content => '{"foo": "bar"}',
    },
    'GET',
    'https://example.com',
);
is($resp->{data}, { foo => 'bar' }, 'parses json content');
is($resp->{content}, '{"foo": "bar"}', 'returns content');

$resp = $http->_handle_response(
    {
        success => 1,
        status  => 200,
        headers => { 'content-type' => 'application/json' },
        content => '{invalid',
    },
    'GET',
    'https://example.com',
);
ok(!defined $resp->{data}, 'invalid json yields undef data');

$resp = $http->_handle_response(
    {
        success => 1,
        status  => 200,
        headers => { 'content-type' => 'text/plain' },
        content => 'hello',
    },
    'GET',
    'https://example.com',
);
ok(!defined $resp->{data}, 'non-json content yields undef data');
is($resp->{content}, 'hello', 'non-json content preserved');

done_testing;
