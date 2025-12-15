#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;
use Dedalus::Version ();
use Try::Tiny;
use Scalar::Util qw(blessed);

my $prompt = shift @ARGV // 'Summarize Dedalus in one sentence.';
my $model  = $ENV{DEDALUS_RESPONSE_MODEL} // 'openai/gpt-5-nano';

my $client = Dedalus->new();

my ($response, $fallback_text);
my $base_url = eval { $client->base_url } // '(unknown)';
my $environment = eval { $client->environment } // '(unknown)';

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
        _report_missing_endpoint(
            base_url    => $base_url,
            environment => $environment,
            model       => $model,
            prompt      => $prompt,
            message     => $msg,
        );
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
        next unless $item->type eq 'message';
        for my $block (@{ $item->content }) {
            my $text = $block->text;
            next unless defined $text;
            print $text, "\n";
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

sub _report_missing_endpoint {
    my (%args) = @_;
    my $base_url    = $args{base_url}    // '(unknown)';
    my $environment = $args{environment} // '(unknown)';
    my $model       = $args{model}       // '(unknown)';
    my $prompt      = $args{prompt}      // '(omitted)';
    my $msg         = $args{message}     // '(no message)';
    my $version     = $Dedalus::Version::VERSION // 'dev';

    warn <<"MSG";
Responses API unavailable (404). Share these details with the Dedalus team to enable /v1/responses on your account (default production host: https://api.dedaluslabs.ai):
  Base URL     : $base_url
  Environment  : $environment
  Model        : $model
  Prompt       : $prompt
  SDK Version  : $version
  Error message: $msg
Falling back to chat completions...
MSG
}
