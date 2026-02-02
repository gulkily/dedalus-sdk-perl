use Test2::V0;

use Dedalus::Util::SSE qw(parse_sse to_stream_events build_decoder);

my $events = parse_sse("event: completion\ndata: {\"foo\":1}\n\n");
is($events, [ { event => 'completion', data => '{"foo":1}' } ], 'parse basic event/data');

$events = parse_sse("data: {\"foo\":2}\n\n");
is($events, [ { data => '{"foo":2}' } ], 'parse data without event');

$events = parse_sse("event: ping\n\n");
is($events, [ { event => 'ping' } ], 'parse event without data');

$events = parse_sse("event: ping\ndata: {\ndata: \"foo\":\ndata: true}\n\n");
is(
    $events,
    [ { event => 'ping', data => "{\n\"foo\":\ntrue}" } ],
    'parse multi-line data',
);

my $chunks = to_stream_events("data: {\"foo\":3}\n\n");
is($chunks, [ { foo => 3 } ], 'to_stream_events decodes json');

$chunks = to_stream_events("data: [DONE]\n\n");
is($chunks, [], 'to_stream_events skips done');

my @decoded;
my $decoder = build_decoder(sub {
    push @decoded, $_[0];
});

$decoder->("data: {\"foo\":4}\n");
$decoder->("\n");
$decoder->("data: [DONE]\n\n");

is($decoded[0], { foo => 4 }, 'build_decoder yields decoded event');
ok(!defined $decoded[1], 'build_decoder yields undef on done');

done_testing;
