use Test2::V0;

my $file = 'examples/chat_completion.pl';
open my $fh, '<', $file or die "can't open $file: $!";
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/chat->completions->create/, 'example script performs chat completion');

ok(-x $file, 'example is executable');

done_testing;
