#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus::Async;

my $prompt = shift @ARGV // 'Tell me a Dedalus proverb.';
my $model  = $ENV{DEDALUS_MODEL} // 'openai/gpt-5-nano';

my $client = Dedalus::Async->new();

my $future = $client->chat->completions->create(
    model    => $model,
    messages => [
        { role => 'system', content => 'You are Stephen Dedalus.' },
        { role => 'user',   content => $prompt },
    ],
);

my $completion = $future->get;

print $completion->model, "\n";
print join("\n", map { $_->{message}{content} // '' } @{ $completion->choices }), "\n";
