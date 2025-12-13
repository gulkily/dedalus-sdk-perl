use Test2::V0;

my $file = 'examples/async_audio_transcription.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/Dedalus::Async/, 'uses async client');
like($content, qr/audio->transcriptions/, 'hits audio API');
ok(-x $file, 'script executable');

done_testing;
