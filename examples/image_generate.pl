#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;
use MIME::Base64 qw(decode_base64);
use File::Spec;

my $prompt = shift @ARGV // $ENV{DEDALUS_IMAGE_PROMPT}
  or die "Usage: DEDALUS_IMAGE_PROMPT=\"a corgi\" perl examples/image_generate.pl [output.png]\n";

my $output = shift @ARGV // $ENV{DEDALUS_IMAGE_OUTPUT} // 'dedalus-image.png';
my $model  = $ENV{DEDALUS_IMAGE_MODEL} // 'openai/gpt-image-1';

my $client = Dedalus->new();

my $response = $client->images->generate(
    prompt          => $prompt,
    model           => $model,
    response_format => 'b64_json',
);

my $image = $response->data->[0];
my $b64   = $image->b64_json
  or die "API did not return b64_json data; try setting response_format => 'url'";

my $bytes = decode_base64($b64);
open my $fh, '>', $output or die "Unable to write $output: $!";
binmode $fh;
print {$fh} $bytes;
close $fh;

print "Saved image to $output\n";
