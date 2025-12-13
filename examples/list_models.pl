#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $client = Dedalus->new();
my $response = $client->models->list;

printf "Found %d models:\n", scalar(@{$response->data});
for my $model (@{$response->data}) {
    printf "- %s (%s)\n", $model->id, $model->provider;
}
