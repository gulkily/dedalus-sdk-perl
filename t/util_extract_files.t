use Test2::V0;

use Dedalus::Util::Files qw(extract_files);

my $query = { foo => 'bar' };
is(extract_files($query, paths => []), [], 'no paths returns empty');
is($query, { foo => 'bar' }, 'no paths leaves query unchanged');

my $query2 = { foo => 'Bar', hello => 'world' };
is(
    extract_files($query2, paths => [ ['foo'] ]),
    [ ['foo', 'Bar'] ],
    'extracts top-level file',
);
is($query2, { hello => 'world' }, 'removes top-level file entry');

my $query3 = { foo => { foo => { bar => 'Bar' } }, hello => 'world' };
is(
    extract_files($query3, paths => [ ['foo', 'foo', 'bar'] ]),
    [ ['foo[foo][bar]', 'Bar'] ],
    'extracts nested file',
);
is(
    $query3,
    { foo => { foo => {} }, hello => 'world' },
    'removes nested file entry',
);

my $query4 = { foo => { bar => 'Bar', baz => 'foo' }, hello => 'world' };
is(
    extract_files($query4, paths => [ ['foo', 'bar'] ]),
    [ ['foo[bar]', 'Bar'] ],
    'extracts nested file in sibling hash',
);
is(
    $query4,
    { foo => { baz => 'foo' }, hello => 'world' },
    'preserves remaining keys',
);

my $query5 = { documents => [ { file => 'My first file' }, { file => 'My second file' } ] };
is(
    extract_files($query5, paths => [ ['documents', '<array>', 'file'] ]),
    [ ['documents[][file]', 'My first file'], ['documents[][file]', 'My second file'] ],
    'extracts files from array entries',
);
is(
    $query5,
    { documents => [ {}, {} ] },
    'removes file keys from array entries',
);

is(
    extract_files({ foo => { bar => 'baz' } }, paths => [ ['foo', '<array>', 'bar'] ]),
    [],
    'ignores dict when array expected',
);
is(
    extract_files({ foo => ['bar', 'baz'] }, paths => [ ['foo', 'bar'] ]),
    [],
    'ignores array when dict expected',
);
is(
    extract_files({ foo => { bar => 'baz' } }, paths => [ ['foo', 'foo'] ]),
    [],
    'ignores unknown keys',
);

done_testing;
