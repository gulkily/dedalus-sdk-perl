use Test2::V0;

my $file = 'examples/image_generate.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/images->generate/, 'image script calls images API');
ok(-x $file, 'script executable');

done_testing;
