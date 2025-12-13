#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $client = Dedalus->new();
my $health = $client->health->check;

print "API status: " . $health->status . "\n";
