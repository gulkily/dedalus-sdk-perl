use Test2::V0;

use Dedalus::Util::Params qw(require_params);

my $params = { foo => 1, bar => 2 };
is(require_params($params, 'foo'), $params, 'returns original hashref');

ok(
    lives { require_params({ foo => 1, bar => 2 }, 'foo', 'bar') },
    'multiple required keys present',
);

like(
    dies { require_params({ foo => 1 }, 'foo', 'bar') },
    qr/bar is required/,
    'missing key croaks',
);

ok(
    lives { require_params({ foo => undef }, 'foo') },
    'undef value allowed if key exists',
);

done_testing;
