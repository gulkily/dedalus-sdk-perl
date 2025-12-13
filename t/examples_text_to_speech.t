use Test2::V0;

my $file = 'examples/text_to_speech.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/audio->speech->create/, 'speech example hits API');
ok(-x $file, 'script executable');

done_testing;
