package Dedalus::Async::Files::Content;
use Moo;
use Future;
use Carp qw(croak);

has client => (
    is       => 'ro',
    required => 1,
);

sub retrieve {
    my ($self, $file_id, %opts) = @_;
    croak 'file_id is required' unless $file_id;
    my $future = $self->client->request_future('GET', "/v1/files/$file_id/content", %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $payload = {
            status  => $res->{status},
            headers => $res->{headers},
            content => $res->{content},
        };
        Future->done($payload);
    });
}

1;
