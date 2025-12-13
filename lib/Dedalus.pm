package Dedalus;
use strict;
use warnings;

use Dedalus::Client;

sub new {
    my ($class, %args) = @_;
    return Dedalus::Client->new(%args);
}

1;
