#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;
use Try::Tiny;

my $prompt = shift @ARGV // 'Summarize Dedalus in one sentence.';
my $model  = $ENV{DEDALUS_RESPONSE_MODEL} // 'openai/gpt-5-nano';

my $client = Dedalus->new();

my $response = try {
    $client->responses->create(
        model => $model,
        input => [
            { role => 'user', content => $prompt },
        ],
    );
} catch {
    die "Error creating response: $_";
};

print "Response ID: " . $response->id . "\n";
if (my $output = $response->output) {
    for my $item (@{$output}) {
        next unless ref $item eq 'HASH';
        next unless ($item->{type} // '') eq 'message';
        my $content = $item->{content};
        if (ref $content eq 'ARRAY') {
            for my $block (@{$content}) {
                next unless ref $block eq 'HASH';
                my $text = $block->{text};
                next unless defined $text;
                print $text, "\n";
            }
        } elsif (!ref $content && defined $content) {
            print $content, "\n";
        }
    }
} else {
    print "Response status: " . ($response->status // 'unknown') . "\n";
}
