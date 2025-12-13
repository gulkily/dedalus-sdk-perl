package Dedalus::Resources::Audio;
use Moo;

use Dedalus::Resources::Audio::Transcriptions;

has client => (
    is       => 'ro',
    required => 1,
);

has transcriptions => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_transcriptions',
);

sub _build_transcriptions {
    my ($self) = @_;
    return Dedalus::Resources::Audio::Transcriptions->new(client => $self->client);
}

1;
