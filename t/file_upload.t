use Test2::V0;
use File::Temp qw(tempfile);

use Dedalus::FileUpload;

my ($fh, $path) = tempfile(SUFFIX => '.txt');
print {$fh} 'hello';
close $fh;

my $upload = Dedalus::FileUpload->from_path($path);
my $field = $upload->to_field;
like($field->{filename}, qr/\.txt$/, 'from_path keeps filename');
is($field->{content}, 'hello', 'from_path reads content');
is($field->{content_type}, 'text/plain', 'from_path infers content type');

my $content_upload = Dedalus::FileUpload->from_content('{"a":1}', filename => 'payload.json');
my $content_field = $content_upload->to_field;
is($content_field->{filename}, 'payload.json', 'from_content uses filename');
is($content_field->{content}, '{"a":1}', 'from_content keeps content');
is($content_field->{content_type}, 'application/json', 'from_content infers content type');

open my $read_fh, '<', $path or die $!;
my $handle_upload = Dedalus::FileUpload->from_handle($read_fh, filename => 'note.txt');
my $handle_field = $handle_upload->to_field;
is($handle_field->{filename}, 'note.txt', 'from_handle uses filename');
is($handle_field->{content}, 'hello', 'from_handle reads content');
is($handle_field->{content_type}, 'text/plain', 'from_handle infers content type');
close $read_fh;

done_testing;
