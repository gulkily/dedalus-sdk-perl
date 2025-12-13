use Test2::V0;

my $file = 'examples/chat_stream.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/stream => 1/, 'example enables streaming');
ok(-x $file, 'script executable');

done_testing;
