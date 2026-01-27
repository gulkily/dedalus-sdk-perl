package Dedalus::Async::Chat::Completions;
use Moo;
use Future;

use Dedalus::Stream;
use Dedalus::Types::Chat::Completion;
use Dedalus::Types::Chat::CompletionChunk;
use Dedalus::Util::SSE qw(build_decoder);

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    if ($params{stream}) {
        my $stream = Dedalus::Stream->new;
        my $decoder = build_decoder(sub {
            my ($event) = @_;
            if (defined $event) {
                my $chunk = Dedalus::Types::Chat::CompletionChunk->from_hash($event);
                $stream->push_chunk($chunk);
            } else {
                $stream->finish;
            }
        });

        my $guard = $self->client->http->stream_request(
            'POST',
            '/v1/chat/completions',
            json     => \%params,
            on_chunk => sub {
                my ($chunk, $meta) = @_;
                if (defined $chunk) {
                    $decoder->($chunk);
                    return;
                }
                if ($meta && $meta->{Status} && $meta->{Status} >= 400) {
                    $stream->push_chunk({ error => $meta->{Reason} });
                }
                $stream->finish;
            },
        );
        $stream->guard($guard);
        return Future->done($stream);
    }

    my $future = $self->client->request_future('POST', '/v1/chat/completions', json => \%params);
    return $future->then(sub {
        my ($res) = @_;
        my $data = $res->{data} || {};
        my $completion = Dedalus::Types::Chat::Completion->from_hash($data);
        Future->done($completion);
    });
}

1;
