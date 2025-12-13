use Test2::V0;

my $file = 'examples/audio_translation.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/audio->translations->create/, 'translation example hits API');
ok(-x $file, 'script executable');

done_testing;
