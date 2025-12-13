#!/usr/bin/env perl
use strict;
use warnings;

use Dedalus::Async;

my $model = $ENV{DEDALUS_EMBEDDING_MODEL} // 'text-embedding-3-small';
my $input = $ENV{DEDALUS_EMBEDDING_INPUT} // 'Hello from Dedalus Perl SDK';

my $client = Dedalus::Async->new();

my $future = $client->embeddings->create(
    model => $model,
    input => $input,
);

my $response = $future->get;
my $vector   = $response->data->[0]->embedding;
my $dim      = ref $vector eq 'ARRAY' ? scalar(@$vector) : length($vector || '');

print "Model: $model\n";
print "Input: $input\n";
print "Embedding dimensions: $dim\n";
