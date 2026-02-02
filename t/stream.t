use Test2::V0;

use Dedalus::Stream;

my $stream = Dedalus::Stream->new;
ok(!$stream->finished, 'stream starts unfinished');
is($stream->to_arrayref, [], 'initial queue empty');

$stream->push_chunk({ foo => 1 });
is($stream->to_arrayref, [ { foo => 1 } ], 'push_chunk adds item');

my $first = $stream->next;
is($first, { foo => 1 }, 'next returns queued item');

$stream->finish;
ok($stream->finished, 'finish marks stream finished');
is($stream->next, undef, 'next returns undef when finished and empty');

$stream->push_chunk({ bar => 2 });
is($stream->to_arrayref, [ { bar => 2 } ], 'push_chunk still queues after finish');

is($stream->to_arrayref, [ { bar => 2 } ], 'to_arrayref returns queued items');
$stream->reset;
is($stream->to_arrayref, [], 'reset clears queue');

done_testing;
