package Dedalus::Client;
use Moo;
use Scalar::Util qw(blessed);

use Dedalus::Config;
use Dedalus::HTTP;
use Dedalus::Resources::Health;
use Dedalus::Resources::Chat;
use Dedalus::Resources::Models;
use Dedalus::Resources::Embeddings;
use Dedalus::Resources::Audio;
use Dedalus::Resources::Images;

has config => (
    is       => 'ro',
    required => 1,
);

has http => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_http',
);

has health => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_health_resource',
);

has chat => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_chat_resource',
);

has models => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_models_resource',
);

has embeddings => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_embeddings_resource',
);

has audio => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_audio_resource',
);

has images => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_images_resource',
);

sub _build_http {
    my ($self) = @_;
    return Dedalus::HTTP->new(config => $self->config);
}

sub _build_health_resource {
    my ($self) = @_;
    return Dedalus::Resources::Health->new(client => $self);
}

sub _build_chat_resource {
    my ($self) = @_;
    return Dedalus::Resources::Chat->new(client => $self);
}

sub _build_models_resource {
    my ($self) = @_;
    return Dedalus::Resources::Models->new(client => $self);
}

sub _build_embeddings_resource {
    my ($self) = @_;
    return Dedalus::Resources::Embeddings->new(client => $self);
}

sub _build_audio_resource {
    my ($self) = @_;
    return Dedalus::Resources::Audio->new(client => $self);
}

sub _build_images_resource {
    my ($self) = @_;
    return Dedalus::Resources::Images->new(client => $self);
}

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    my $config = delete $args{config};
    if ($config) {
        die 'config must be a Dedalus::Config' unless blessed($config) && $config->isa('Dedalus::Config');
    } else {
        $config = Dedalus::Config->new(%args);
    }

    $args{config} = $config;

    return $class->$orig(%args);
};

sub api_key     { shift->config->api_key }
sub base_url    { shift->config->base_url }
sub timeout     { shift->config->timeout }
sub headers     { shift->config->headers }
sub environment { shift->config->environment }

sub request {
    my ($self, $method, $path, %opts) = @_;
    return $self->http->request($method, $path, %opts);
}

1;
