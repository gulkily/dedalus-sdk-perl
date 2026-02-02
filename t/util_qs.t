use Test2::V0;
use URI::Escape qw(uri_unescape);
use Cpanel::JSON::XS ();

use Dedalus::Util::QS qw(stringify);
use Dedalus::Util::QS;

sub unescape {
    return uri_unescape(shift);
}

is(stringify({}), '', 'empty params');
is(stringify({ a => {} }), '', 'empty nested hash');
is(stringify({ a => { b => { c => {} } } }), '', 'empty deep nested hash');

is(stringify({ a => 1 }), 'a=1', 'basic number');
is(stringify({ a => 'b' }), 'a=b', 'basic string');
is(stringify({ a => Cpanel::JSON::XS::true() }), 'a=true', 'basic true');
is(stringify({ a => Cpanel::JSON::XS::false() }), 'a=false', 'basic false');
is(stringify({ a => 1.23456 }), 'a=1.23456', 'basic float');
is(stringify({ a => undef }), '', 'undef omitted');

for my $method (qw(class function)) {
    my $serialise = $method eq 'class'
        ? Dedalus::Util::QS->new(nested_format => 'dots')->can('stringify')
        : \&stringify;
    my @args = $method eq 'class' ? (Dedalus::Util::QS->new(nested_format => 'dots')) : ();

    is(
        unescape($serialise->(@args, { a => { b => 'c' } }, nested_format => 'dots')),
        'a.b=c',
        "$method nested dotted",
    );
    is(
        unescape($serialise->(@args, { a => { b => 'c', d => 'e', f => 'g' } }, nested_format => 'dots')),
        'a.b=c&a.d=e&a.f=g',
        "$method nested dotted multi",
    );
    is(
        unescape($serialise->(@args, { a => { b => { c => { d => 'e' } } } }, nested_format => 'dots')),
        'a.b.c.d=e',
        "$method nested dotted deep",
    );
    is(
        unescape($serialise->(@args, { a => { b => Cpanel::JSON::XS::true() } }, nested_format => 'dots')),
        'a.b=true',
        "$method nested dotted boolean",
    );
}

is(
    unescape(stringify({ a => { b => 'c' } })),
    'a[b]=c',
    'nested brackets',
);
is(
    unescape(stringify({ a => { b => 'c', d => 'e', f => 'g' } })),
    'a[b]=c&a[d]=e&a[f]=g',
    'nested brackets multi',
);
is(
    unescape(stringify({ a => { b => { c => { d => 'e' } } } })),
    'a[b][c][d]=e',
    'nested brackets deep',
);
is(
    unescape(stringify({ a => { b => Cpanel::JSON::XS::true() } })),
    'a[b]=true',
    'nested brackets boolean',
);

for my $method (qw(class function)) {
    my $serialise = $method eq 'class'
        ? Dedalus::Util::QS->new(array_format => 'comma')->can('stringify')
        : \&stringify;
    my @args = $method eq 'class' ? (Dedalus::Util::QS->new(array_format => 'comma')) : ();

    is(
        unescape($serialise->(@args, { in => ['foo', 'bar'] }, array_format => 'comma')),
        'in=foo,bar',
        "$method array comma",
    );
    is(
        unescape($serialise->(@args, { a => { b => [ Cpanel::JSON::XS::true(), Cpanel::JSON::XS::false() ] } }, array_format => 'comma')),
        'a[b]=true,false',
        "$method array comma nested",
    );
    is(
        unescape($serialise->(@args, { a => { b => [ Cpanel::JSON::XS::true(), Cpanel::JSON::XS::false(), undef, Cpanel::JSON::XS::true() ] } }, array_format => 'comma')),
        'a[b]=true,false,true',
        "$method array comma skip undef",
    );
}

is(
    unescape(stringify({ in => ['foo', 'bar'] })),
    'in=foo&in=bar',
    'array repeat',
);
is(
    unescape(stringify({ a => { b => [ Cpanel::JSON::XS::true(), Cpanel::JSON::XS::false() ] } })),
    'a[b]=true&a[b]=false',
    'array repeat nested',
);
is(
    unescape(stringify({ a => { b => [ Cpanel::JSON::XS::true(), Cpanel::JSON::XS::false(), undef, Cpanel::JSON::XS::true() ] } })),
    'a[b]=true&a[b]=false&a[b]=true',
    'array repeat skip undef',
);
is(
    unescape(stringify({ in => ['foo', { b => { c => ['d', 'e'] } } ] })),
    'in=foo&in[b][c]=d&in[b][c]=e',
    'array repeat nested hash',
);

for my $method (qw(class function)) {
    my $serialise = $method eq 'class'
        ? Dedalus::Util::QS->new(array_format => 'brackets')->can('stringify')
        : \&stringify;
    my @args = $method eq 'class' ? (Dedalus::Util::QS->new(array_format => 'brackets')) : ();

    is(
        unescape($serialise->(@args, { in => ['foo', 'bar'] }, array_format => 'brackets')),
        'in[]=foo&in[]=bar',
        "$method array brackets",
    );
    is(
        unescape($serialise->(@args, { a => { b => [ Cpanel::JSON::XS::true(), Cpanel::JSON::XS::false() ] } }, array_format => 'brackets')),
        'a[b][]=true&a[b][]=false',
        "$method array brackets nested",
    );
    is(
        unescape($serialise->(@args, { a => { b => [ Cpanel::JSON::XS::true(), Cpanel::JSON::XS::false(), undef, Cpanel::JSON::XS::true() ] } }, array_format => 'brackets')),
        'a[b][]=true&a[b][]=false&a[b][]=true',
        "$method array brackets skip undef",
    );
}

like(
    dies { stringify({ a => ['foo', 'bar'] }, array_format => 'foo') },
    qr/Unknown array_format value: foo, choose from comma, repeat, indices, brackets/,
    'unknown array format',
);

like(
    dies { stringify({ a => ['foo', 'bar'] }, array_format => 'indices') },
    qr/The array indices format is not supported yet/,
    'indices array format not supported',
);

done_testing;
