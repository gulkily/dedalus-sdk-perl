package Dedalus::Resources::Chat::Completions;
use Moo;

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    die 'not implemented yet';
}

1;
