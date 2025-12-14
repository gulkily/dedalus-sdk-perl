#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;
use Try::Tiny;
use Scalar::Util qw(blessed);

my $prompt = shift @ARGV // 'Summarize Dedalus in one sentence.';
my $model  = $ENV{DEDALUS_RESPONSE_MODEL} // 'openai/gpt-5-nano';

my $client = Dedalus->new();

my ($response, $fallback_text);
try {
    $response = $client->responses->create(
        model => $model,
        input => [
            { role => 'user', content => $prompt },
        ],
    );
} catch {
    my $err = $_;
    my ($msg, $status) = _extract_error($err);
    if (defined $status && $status == 404) {
        warn "Responses API unavailable (404); falling back to chat completions...\n";
        $fallback_text = _fallback_chat_completion($client, $model, $prompt);
    } else {
        die "Error creating response: $msg\n";
    }
};

if (defined $fallback_text) {
    print "Fallback response:\n$fallback_text\n";
    exit 0;
}

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

sub _fallback_chat_completion {
    my ($client, $model, $prompt) = @_;
    my $completion = $client->chat->completions->create(
        model    => $ENV{DEDALUS_MODEL} // $model,
        messages => [
            { role => 'system', content => 'You are Stephen Dedalus.' },
            { role => 'user',   content => $prompt },
        ],
    );
    my @lines;
    for my $choice (@{ $completion->choices }) {
        my $text = $choice->{message}{content};
        push @lines, $text if defined $text;
    }
    return join("\n", @lines) || '(no text returned)';
}
