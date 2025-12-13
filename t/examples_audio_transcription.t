use Test2::V0;

my $file = 'examples/audio_transcription.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/audio->transcriptions->create/, 'audio script calls transcriptions');
ok(-x $file, 'audio script executable');

done_testing;
