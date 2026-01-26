#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;
use Dedalus::Runner;

sub get_weather {
    my (%args) = @_;
    my $location = $args{location} // 'unknown';
    return "The weather in $location is sunny and 72F";
}

my $client = Dedalus->new();
my $runner = Dedalus::Runner->new(client => $client);

my $input = $ARGV[0] // 'What is the weather in San Francisco?';

my $result = $runner->run(
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

print "Final: ", ($result->final_output // ''), "\n";
