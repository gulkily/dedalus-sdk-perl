package Dedalus::Async::Audio::Speech;
use Moo;
use Future;

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    my $future = $self->client->request_future(
        'POST',
        '/v1/audio/speech',
        headers => { Accept => 'audio/mpeg' },
        json    => \%params,
    );

    return $future->then(sub {
        my ($res) = @_;
        my $payload = {
            content => $res->{content},
            headers => $res->{headers},
            status  => $res->{status},
        };
        Future->done($payload);
    });
}

1;
