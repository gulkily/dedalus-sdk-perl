#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $prompt = shift @ARGV // 'Summarize Dedalus in one sentence.';
my $model  = $ENV{DEDALUS_RESPONSE_MODEL} // 'openai/gpt-5-nano';

my $client = Dedalus->new();

my $response = $client->responses->create(
    model => $model,
    input => [
        { role => 'user', content => $prompt },
    ],
);

print "Response ID: " . $response->id . "\n";
if (my $output = $response->output) {
    for my $item (@{$output}) {
        next unless ref $item eq 'HASH' && $item->{type} && $item->{type} eq 'message';
        my $content = $item->{content};
        if (ref $content eq 'ARRAY') {
            for my $block (@$content) {
                print ($block->{text} // ''), "\n" if ref $block eq 'HASH';
            }
        } elsif (!ref $content) {
            print $content, "\n";
        }
    }
} else {
    print "Response status: " . ($response->status // 'unknown') . "\n";
}
