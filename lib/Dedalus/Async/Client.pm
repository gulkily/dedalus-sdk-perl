package Dedalus::Async::Client;
use Moo;
use Scalar::Util qw(blessed);
use Future;
use AnyEvent;

use Dedalus::Config;
use Dedalus::HTTP;

has config => (
    is       => 'ro',
    required => 1,
);

has http => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_http',
);

sub _build_http {
    my ($self) = @_;
    return Dedalus::HTTP->new(config => $self->config);
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
