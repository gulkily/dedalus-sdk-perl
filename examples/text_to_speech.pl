#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $text   = shift @ARGV // $ENV{DEDALUS_TTS_TEXT} // 'Hello from Dedalus Perl SDK';
my $output = shift @ARGV // $ENV{DEDALUS_TTS_OUTPUT} // 'speech.mp3';
my $model  = $ENV{DEDALUS_TTS_MODEL}  // 'openai/tts-1';
my $voice  = $ENV{DEDALUS_TTS_VOICE}  // 'alloy';
my $format = $ENV{DEDALUS_TTS_FORMAT} // 'mp3';

my $client = Dedalus->new();

my $response = $client->audio->speech->create(
    model           => $model,
    input           => $text,
    voice           => $voice,
    response_format => $format,
);

open my $fh, '>', $output or die "Unable to write $output: $!";
binmode $fh;
print {$fh} $response->{content};
close $fh;

print "Saved synthesized audio to $output\n";
