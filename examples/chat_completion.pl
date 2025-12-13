#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $client = Dedalus->new();

my $completion = $client->chat->completions->create(
    model    => $ENV{DEDALUS_MODEL} // 'openai/gpt-5-nano',
    messages => [
        {
            role    => 'user',
            content => 'Hello Dedalus, how are you today?',
        },
    ],
);

my $message = $completion->choices->[0]->message->content // '';
print "Assistant: $message\n";
