use Test2::V0;
use File::Temp qw(tempfile);

use Dedalus::FileUpload;

use Dedalus::Util::Files qw(extract_files);

like(
    dies { extract_files('nope', paths => []) },
    qr/query must be hashref/,
    'requires hashref query',
);

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

my $query6 = { files => [ 'a', 'b' ] };
is(
    extract_files($query6, paths => [ ['files'] ]),
    [ ['files[]', 'a'], ['files[]', 'b'] ],
    'extracts files from array leaf',
);
is($query6, {}, 'removes array leaf key');

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

my $scalar = "hello";
my $scalar_query = { file => \$scalar };
is(
    extract_files($scalar_query, paths => [ ['file'] ]),
    [ ['file', \$scalar] ],
    'extracts scalar ref file content',
);
is($scalar_query, {}, 'removes scalar ref entry');

my $hash_query = { file => { content => 'data', filename => 'note.txt' } };
is(
    extract_files($hash_query, paths => [ ['file'] ]),
    [ ['file', { content => 'data', filename => 'note.txt' } ] ],
    'extracts hash content payload',
);
is($hash_query, {}, 'removes hash content entry');

my ($fh, $path) = tempfile();
print {$fh} 'filedata';
close $fh;

my $path_query = { file => { path => $path } };
is(
    extract_files($path_query, paths => [ ['file'] ]),
    [ ['file', { path => $path } ] ],
    'extracts hash path payload',
);
is($path_query, {}, 'removes hash path entry');

open my $read_fh, '<', $path or die $!;
my $handle_query = { file => { handle => $read_fh } };
is(
    extract_files($handle_query, paths => [ ['file'] ]),
    [ ['file', { handle => $read_fh } ] ],
    'extracts hash handle payload',
);
is($handle_query, {}, 'removes hash handle entry');
close $read_fh;

my $upload = Dedalus::FileUpload->from_content('upload');
my $upload_query = { file => $upload };
is(
    extract_files($upload_query, paths => [ ['file'] ]),
    [ ['file', $upload ] ],
    'extracts Dedalus::FileUpload payload',
);
is($upload_query, {}, 'removes upload entry');

like(
    dies { extract_files({ file => { foo => 'bar' } }, paths => [ ['file'] ]) },
    qr/Expected entry at `file` to be file content/,
    'invalid hash payload croaks',
);

like(
    dies { extract_files({ files => [ { foo => 'bar' } ] }, paths => [ ['files', '<array>'] ]) },
    qr/Expected entry at `files\[\]` to be file content/,
    'invalid array entry croaks',
);

done_testing;
