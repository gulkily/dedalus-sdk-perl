#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

use Dedalus;

my $prompt = shift @ARGV // die "Usage: perl script/debug_image_generate.pl \"prompt\" [output.png]\n";
my $output = shift @ARGV // 'image.png';
my $model  = $ENV{DEDALUS_IMAGE_MODEL} // 'openai/gpt-image-1';

my $client = Dedalus->new();

eval {
    my $resp = $client->images->generate(
        prompt => $prompt,
        model  => $model,
    );

    my $image = $resp->data->[0];
    die "No image returned" unless $image;

    if (my $b64 = $image->b64_json) {
        require MIME::Base64;
        my $bytes = MIME::Base64::decode_base64($b64);
        open my $fh, '>', $output or die "Unable to write $output: $!";
        binmode $fh;
        print {$fh} $bytes;
        close $fh;
        print "Saved image to $output\n";
    } elsif (my $url = $image->url) {
        print "Image URL: $url\n";
        print "Download manually if needed.\n";
    } else {
        die "API returned no usable image data";
    }
    1;
} or do {
    my $err = $@;
    warn "Image generation failed\n";
    warn "Status: " . ($err->http_status // 'n/a') . "\n";
    warn Dumper($err->body);
};
