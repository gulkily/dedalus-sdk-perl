package Dedalus::Async::Chat;
use Moo;

use Dedalus::Async::Chat::Completions;

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
    return Dedalus::Async::Chat::Completions->new(client => $self->client);
}

1;
