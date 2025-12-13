#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus;

my $client = Dedalus->new();

my $model = $ENV{DEDALUS_EMBEDDING_MODEL} // 'text-embedding-3-small';
my $input = $ENV{DEDALUS_EMBEDDING_INPUT} // 'Hello from Dedalus Perl SDK';

my $response = $client->embeddings->create(
    model => $model,
    input => $input,
);

my $vector = $response->data->[0]->embedding;
my $dim    = ref $vector eq 'ARRAY' ? scalar(@$vector) : length($vector || '');

print "Model: $model\n";
print "Input: $input\n";
print "Embedding dimensions: $dim\n";
