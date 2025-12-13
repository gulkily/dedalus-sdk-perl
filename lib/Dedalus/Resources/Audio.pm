package Dedalus::Resources::Audio;
use Moo;

use Dedalus::Resources::Audio::Transcriptions;
use Dedalus::Resources::Audio::Translations;
use Dedalus::Resources::Audio::Speech;

has client => (
    is       => 'ro',
    required => 1,
);

has transcriptions => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_transcriptions',
);

has translations => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_translations',
);

has speech => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_speech',
);

sub _build_transcriptions {
    my ($self) = @_;
    return Dedalus::Resources::Audio::Transcriptions->new(client => $self->client);
}

sub _build_translations {
    my ($self) = @_;
    return Dedalus::Resources::Audio::Translations->new(client => $self->client);
}

sub _build_speech {
    my ($self) = @_;
    return Dedalus::Resources::Audio::Speech->new(client => $self->client);
}

1;
