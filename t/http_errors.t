use Test2::V0;

use Dedalus::HTTP;
use Dedalus::Config;

my $http = Dedalus::HTTP->new(config => Dedalus::Config->new(api_key => 'test'));

my $err = dies {
    $http->_raise_error({
        status  => 400,
        reason  => 'Bad Request',
        content => '{"error":{"message":"bad"}}',
    });
};
isa_ok($err, 'Dedalus::Exception::BadRequestError');
is($err->message, 'bad', 'message parsed from body');

$err = dies {
    $http->_raise_error({
        status  => 401,
        reason  => 'Unauthorized',
        content => '{"error":{"message":"nope"}}',
    });
};
isa_ok($err, 'Dedalus::Exception::AuthenticationError');

$err = dies {
    $http->_raise_error({
        status  => 403,
        reason  => 'Forbidden',
        content => '{"error":{"message":"no"}}',
    });
};
isa_ok($err, 'Dedalus::Exception::PermissionDeniedError');

$err = dies {
    $http->_raise_error({
        status  => 404,
        reason  => 'Not Found',
        content => '{"error":{"message":"missing"}}',
    });
};
isa_ok($err, 'Dedalus::Exception::NotFoundError');

$err = dies {
    $http->_raise_error({
        status  => 408,
        reason  => 'Timeout',
        content => 'timeout',
    });
};
isa_ok($err, 'Dedalus::Exception::APITimeoutError');

$err = dies {
    $http->_raise_error({
        status  => 429,
        reason  => 'Rate Limit',
        content => '{"error":{"message":"slow down"}}',
    });
};
isa_ok($err, 'Dedalus::Exception::RateLimitError');

$err = dies {
    $http->_raise_error({
        status  => 500,
        reason  => 'Server Error',
        content => '{"error":{"message":"boom"}}',
    });
};
isa_ok($err, 'Dedalus::Exception::InternalServerError');

$err = dies {
    $http->_raise_error({
        status  => undef,
        reason  => 'Connection',
        content => '',
    });
};
isa_ok($err, 'Dedalus::Exception::APIConnectionError');

done_testing;
