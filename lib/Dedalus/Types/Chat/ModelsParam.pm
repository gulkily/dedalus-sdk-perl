package Dedalus::Types::Chat::ModelsParam;
use strict;
use warnings;

use Dedalus::Types::Shared::DedalusModelChoice;

sub from_value {
    my ($class, $value) = @_;
    return [] unless defined $value;
    die 'expected array ref' unless ref $value eq 'ARRAY';
    my @items = map { Dedalus::Types::Shared::DedalusModelChoice->from_value($_) } @$value;
    return \@items;
}

1;
