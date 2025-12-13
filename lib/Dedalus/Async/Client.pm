package Dedalus::Async::Client;
use Moo;
use Scalar::Util qw(blessed);
use Future;
use AnyEvent;

use Dedalus::Config;
use Dedalus::HTTP;
use Dedalus::Async::Chat;
use Dedalus::Async::Audio;
use Dedalus::Async::Embeddings;
use Dedalus::Async::Images;
use Dedalus::Async::Models;
use Dedalus::Async::Health;

has config => (
    is       => 'ro',
    required => 1,
);

has http => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_http',
);

has chat => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_chat',
);

has audio => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_audio',
);

has embeddings => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_async_embeddings',
);

has images => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_async_images',
);

has models => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_models',
);

has health => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_health',
);

sub _build_http {
    my ($self) = @_;
    return Dedalus::HTTP->new(config => $self->config);
}

sub _build_chat {
    my ($self) = @_;
    return Dedalus::Async::Chat->new(client => $self);
}

sub _build_audio {
    my ($self) = @_;
    return Dedalus::Async::Audio->new(client => $self);
}

sub _build_async_embeddings {
    my ($self) = @_;
    return Dedalus::Async::Embeddings->new(client => $self);
}

sub _build_async_images {
    my ($self) = @_;
    return Dedalus::Async::Images->new(client => $self);
}

sub _build_models {
    my ($self) = @_;
    return Dedalus::Async::Models->new(client => $self);
}

sub _build_health {
    my ($self) = @_;
    return Dedalus::Async::Health->new(client => $self);
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

sub request_future {
    my ($self, $method, $path, %opts) = @_;
    my $cv = AnyEvent->condvar;
    my $future = Future->new;
    my $guard;

    $guard = AnyEvent->idle(sub {
        undef $guard;
        my $res;
        eval {
            $res = $self->http->request($method, $path, %opts);
            1;
        } or do {
            my $err = $@;
            $future->fail($err);
            return;
        };
        $future->done($res);
    });

    return $future;
}

1;
