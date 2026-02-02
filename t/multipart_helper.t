use Test2::V0;
use File::Temp qw(tempfile);

use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);
use Dedalus::FileUpload;

my ($fh, $filename) = tempfile();
print {$fh} 'hello';
close $fh;

my $field = normalize_file_field($filename);
like($field->{filename}, qr/\w/, 'filename derived');
is($field->{content}, 'hello', 'content read');

my $scalar = "world";
$field = normalize_file_field(\$scalar, 'foo.txt');
is($field->{filename}, 'foo.txt', 'default filename used');
is($field->{content}, 'world', 'scalar content used');

{
    package DummyPath;
    sub new {
        my ($class, $content) = @_;
        bless { content => $content }, $class;
    }
    sub slurp_raw {
        my ($self) = @_;
        return $self->{content};
    }
}

$field = normalize_file_field(DummyPath->new('dummy data'));
is($field->{content}, 'dummy data', 'path-like object supported');

open my $fh_read, '<', $filename or die $!;
my $handle_field = normalize_file_field($fh_read, 'handle.bin');
is($handle_field->{filename}, 'handle.bin', 'filename applied for handle');
is($handle_field->{content}, 'hello', 'content slurped from handle');

my ($json_fh, $json_path) = tempfile(SUFFIX => '.jsonl');
print {$json_fh} "{\"a\":1}\n";
close $json_fh;

my $upload = Dedalus::FileUpload->from_path($json_path);
my $upload_field = normalize_file_field($upload);
is($upload_field->{content_type}, 'application/jsonl', 'content type guessed from extension');

my ($boundary, $body) = build_multipart_body({
    file => normalize_file_field($filename),
    model => 'openai/whisper-1',
    metadata => { foo => 'bar' },
});

like($boundary, qr/DedalusBoundary/, 'boundary produced');
like($body, qr/Content-Disposition: form-data; name=\"model\"/, 'includes model field');
like($body, qr/\{\"foo\":\"bar\"\}/, 'metadata encoded as JSON');

ok($body =~ /hello/, 'includes file bytes');

like(
    dies { normalize_file_field({ foo => 'bar' }) },
    qr/file hash must include content, path, or handle/,
    'invalid file hash croaks',
);

open my $closed_fh, '<', $filename or die $!;
close $closed_fh;
like(
    dies { normalize_file_field({ handle => $closed_fh }) },
    qr/handle must be an open filehandle/,
    'closed handle croaks',
);

my ($boundary2, $body2) = build_multipart_body({
    file => normalize_file_field($filename),
    omit => undef,
});
like($body2, qr/name="file"/, 'includes file field');
unlike($body2, qr/name="omit"/, 'skips undef field');

done_testing;
