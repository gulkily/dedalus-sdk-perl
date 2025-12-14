use Test2::V0;

use Dedalus::Util::Params qw(require_params ensure_arrayref deep_copy);

my $params = require_params({ foo => 1, bar => 2 }, 'foo');
is($params->{foo}, 1, 'require_params passes through hashref');

like(dies { require_params({ }, 'foo') }, qr/foo is required/, 'missing key croaks');

my $arr = ensure_arrayref('hello', 'input');
is($arr, ['hello'], 'scalar coerced to arrayref');

$arr = ensure_arrayref([1,2], 'input');
is($arr, [1,2], 'arrayref returned as-is');

like(dies { ensure_arrayref({ foo => 1 }, 'input') }, qr/input must be an array reference or scalar/, 'invalid ref croaks');

my $orig = { a => [1, { b => 2 }] };
my $copy = deep_copy($orig);
$copy->{a}[1]{b} = 3;

is($orig->{a}[1]{b}, 2, 'deep_copy clones nested structures');

done_testing;
