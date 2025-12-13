#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

$| = 1; # autoflush so chunks appear immediately
binmode STDOUT, ':encoding(UTF-8)';

my $prompt = shift @ARGV // 'Write a haiku about Dublin rain.';
my $model  = $ENV{DEDALUS_MODEL} // 'openai/gpt-5-nano';

my $client = Dedalus->new();

my $stream = $client->chat->completions->create(
    model    => $model,
    stream   => 1,
    messages => [
        { role => 'system', content => 'You are Stephen Dedalus.' },
        { role => 'user',   content => $prompt },
    ],
);

print "Streaming response (model: $model)\n";
while (my $chunk = $stream->next) {
    my $delta = $chunk->{choices}[0]{delta}{content} // '';
    next unless length $delta;
    print $delta;
}
print "\n";
