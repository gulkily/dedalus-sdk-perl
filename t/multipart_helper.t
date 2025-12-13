use Test2::V0;
use File::Temp qw(tempfile);

use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);

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

my ($boundary, $body) = build_multipart_body({
    file => normalize_file_field($filename),
    model => 'openai/whisper-1',
});

like($boundary, qr/DedalusBoundary/, 'boundary produced');
like($body, qr/Content-Disposition: form-data; name=\"model\"/, 'includes model field');

ok($body =~ /hello/, 'includes file bytes');

done_testing;
