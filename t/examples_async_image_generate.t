use Test2::V0;

my $file = 'examples/async_image_generate.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/images->generate/, 'async image script calls image API');
ok(-x $file, 'script executable');

done_testing;
