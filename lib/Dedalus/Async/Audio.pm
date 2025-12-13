package Dedalus::Async::Audio;
use Moo;

use Dedalus::Async::Audio::Transcriptions;
use Dedalus::Async::Audio::Translations;
use Dedalus::Async::Audio::Speech;

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
    return Dedalus::Async::Audio::Transcriptions->new(client => $self->client);
}

sub _build_translations {
    my ($self) = @_;
    return Dedalus::Async::Audio::Translations->new(client => $self->client);
}

sub _build_speech {
    my ($self) = @_;
    return Dedalus::Async::Audio::Speech->new(client => $self->client);
}

1;
