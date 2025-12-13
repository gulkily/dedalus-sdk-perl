package Dedalus::Resources::Chat;
use Moo;

use Dedalus::Resources::Chat::Completions;

has client => (
    is       => 'ro',
    required => 1,
);

has completions => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_completions',
);

sub _build_completions {
    my ($self) = @_;
    return Dedalus::Resources::Chat::Completions->new(client => $self->client);
}

1;
