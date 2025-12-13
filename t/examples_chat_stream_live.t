use Test2::V0;

my $file = 'examples/chat_stream_live.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/stream\s*=>\s*1/, 'stream parameter used');
ok(-x $file, 'script executable');

like($content, qr/\$\|\s*=\s*1/, 'autoflush enabled');

done_testing;
