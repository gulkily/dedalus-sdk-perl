#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;
use Getopt::Long qw(GetOptions);

my $file;
my $model = $ENV{DEDALUS_TRANSLATION_MODEL} // 'openai/whisper-1';

GetOptions(
    'file=s'  => \$file,
    'model=s' => \$model,
);

$file ||= shift @ARGV;
$file ||= $ENV{DEDALUS_AUDIO_FILE};

die "Usage: perl examples/audio_translation.pl --file path/to/audio.wav\n"
  unless $file;

my $client = Dedalus->new();

my $response = $client->audio->translations->create(
    model => $model,
    file  => $file,
);

print "Model: $model\n";
print "Transcript:\n" . $response->text . "\n";
