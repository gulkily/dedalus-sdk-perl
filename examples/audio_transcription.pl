#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $file = shift @ARGV // $ENV{DEDALUS_AUDIO_FILE}
  or die "Usage: DEDALUS_AUDIO_FILE=path perl examples/audio_transcription.pl\n";

my $model = $ENV{DEDALUS_TRANSCRIPTION_MODEL} // 'openai/whisper-1';

my $client = Dedalus->new();

my $response = $client->audio->transcriptions->create(
    model => $model,
    file  => $file,
);

print "Model: $model\n";
print "File:  $file\n";
print "Transcript:\n" . $response->text . "\n";
