#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus::Async;
use MIME::Base64 qw(decode_base64);

my $prompt = shift @ARGV // $ENV{DEDALUS_IMAGE_PROMPT}
  or die "Usage: DEDALUS_IMAGE_PROMPT=\"a corgi\" perl examples/async_image_generate.pl [output.png]\n";

my $output = shift @ARGV // $ENV{DEDALUS_IMAGE_OUTPUT} // 'dedalus-image.png';
my $model  = $ENV{DEDALUS_IMAGE_MODEL} // 'openai/gpt-image-1';

my $client = Dedalus::Async->new();

my $future = $client->images->generate(
    prompt => $prompt,
    model  => $model,
);

my $response = $future->get;
my $image    = $response->data->[0];
if (my $b64 = $image->b64_json) {
    my $bytes = decode_base64($b64);
    open my $fh, '>', $output or die "Unable to write $output: $!";
    binmode $fh;
    print {$fh} $bytes;
    close $fh;
    print "Saved image to $output\n";
} elsif (my $url = $image->url) {
    print "Image available at: $url\n";
    print "Download manually if needed.\n";
} else {
    die "API returned no image data";
}
