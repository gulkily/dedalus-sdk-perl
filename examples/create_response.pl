#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;
use Try::Tiny;
use Scalar::Util qw(blessed);

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
    my $err = $_;
    my ($msg, $status) = _extract_error($err);
    if (defined $status && $status == 404) {
        die "Responses API unavailable (404). Ensure your Dedalus environment exposes /v1/responses or update DEDALUS_BASE_URL.\nOriginal error: $msg\n";
    }
    die "Error creating response: $msg\n";
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

sub _extract_error {
    my ($err) = @_;
    if (blessed($err)) {
        my $msg = $err->can('message') ? $err->message : "$err";
        my $status = $err->can('http_status') ? $err->http_status : undef;
        return ($msg, $status);
    }
    return ($err, undef);
}
