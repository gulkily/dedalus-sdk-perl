package Dedalus::Async::Chat::Completions;
use Moo;
use Future;

use Dedalus::Types::Chat::Completion;

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    my $future = $self->client->request_future('POST', '/v1/chat/completions', json => \%params);
    $future = $future->then(sub {
        my ($res) = @_;
        my $data = $res->{data} || {};
        my $completion = Dedalus::Types::Chat::Completion->from_hash($data);
        Future->done($completion);
    });
    return $future;
}

1;
