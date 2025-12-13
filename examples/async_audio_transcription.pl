#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus::Async;

my $file = shift @ARGV or die "Usage: perl examples/async_audio_transcription.pl /path/to/audio.wav\n";

my $client = Dedalus::Async->new();

my $future = $client->audio->transcriptions->create(
    model => $ENV{DEDALUS_TRANSCRIPTION_MODEL} // 'openai/whisper-1',
    file  => $file,
);

my $resp = $future->get;
print $resp->text, "\n";
