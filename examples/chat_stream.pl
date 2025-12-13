#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $client = Dedalus->new();

my $stream = $client->chat->completions->create(
    model    => $ENV{DEDALUS_MODEL} // 'openai/gpt-5-nano',
    stream   => 1,
    messages => [
        { role => 'system', content => 'You are Stephen Dedalus.' },
        { role => 'user',   content => $ARGV[0] // 'Describe the sea at dawn.' },
    ],
);

print "Streaming response:\n";
while (my $chunk = $stream->next) {
    my $delta = $chunk->{choices}[0]{delta}{content} // '';
    print $delta;
}
print "\n";
