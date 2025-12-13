package Dedalus::Async;
use strict;
use warnings;

use Dedalus::Async::Client;

sub new {
    my ($class, %args) = @_;
    return Dedalus::Async::Client->new(%args);
}

1;
