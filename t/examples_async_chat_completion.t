use Test2::V0;

my $file = 'examples/async_chat_completion.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/Dedalus::Async/, 'uses async client');
ok(-x $file, 'script is executable');

done_testing;
