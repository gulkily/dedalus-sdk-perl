use Test2::V0;
use Cpanel::JSON::XS qw(encode_json);
use Test::MockModule;
use Dedalus;

my $http_mock = Test::MockModule->new('Dedalus::HTTP');
my $orig_stream = Dedalus::HTTP->can('stream_request');
$http_mock->mock('stream_request', sub {
    my ($self, $method, $path, %opts) = @_;
    if ($path eq '/v1/images/generations') {
        my $cb = $opts{on_chunk};
        my $payload = encode_json({ type => 'image.partial', index => 0, image => { index => 0, b64_json => 'AAA', status => 'partial' } });
        $cb->("data: $payload\n\n");
        $cb->("data: [DONE]\n\n", { Status => 200 });
        return bless {}, 'Guard';
    }
    return $orig_stream->($self, $method, $path, %opts);
});

my $client = Dedalus->new(api_key => 'test');

my $stream = $client->images->generate(prompt => 'streaming image', stream => 1);
isa_ok($stream, 'Dedalus::Stream');
my $event = $stream->next;
isa_ok($event, 'Dedalus::Types::Image::StreamEvent');
is($event->image->b64_json, 'AAA', 'image chunk parsed');

$http_mock->unmock_all;

done_testing;
