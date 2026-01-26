#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus::Async;
use Future;

sub get_weather {
    my (%args) = @_;
    my $location = $args{location} // 'unknown';
    return Future->done("The weather in $location is sunny and 72F");
}

my $client = Dedalus::Async->new();
my $runner = $client->runner;

my $input = $ARGV[0] // 'What is the weather in San Francisco?';

my $future = $runner->run(
    model => $ENV{DEDALUS_MODEL} // 'openai/gpt-5-nano',
    input => $input,
    tools => [
        {
            name        => 'get_weather',
            description => 'Return the weather for a location',
            parameters  => {
                type       => 'object',
                properties => {
                    location => { type => 'string' },
                },
                required => ['location'],
            },
            handler => \&get_weather,
        },
    ],
    max_steps => 3,
);

my $result = $future->get;
print "Final: ", ($result->final_output // ''), "\n";
