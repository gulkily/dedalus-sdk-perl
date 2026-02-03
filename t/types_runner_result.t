use Test2::V0;

use Dedalus::Types::Runner::RunResult;

my $result = Dedalus::Types::Runner::RunResult->from_hash({
    output      => 'legacy output',
    content     => 'legacy content',
    tool_results => [
        { name => 'tool', result => 1, step => 1 },
    ],
    steps_used  => 1,
    tools_called => [ 'tool' ],
    messages    => [ { role => 'user', content => 'hi' } ],
});

is($result->final_output, 'legacy output', 'output alias used for final_output');
is($result->tool_results->[0]->name, 'tool', 'tool result parsed');

my $result2 = Dedalus::Types::Runner::RunResult->from_hash({
    content     => 'legacy content',
    tool_results => [],
    steps_used  => 0,
    tools_called => [],
    messages    => [ { role => 'user', content => 'hi' } ],
});

is($result2->final_output, 'legacy content', 'content alias used for final_output');

my $copy = $result->to_input_list;
is($copy, [ { role => 'user', content => 'hi' } ], 'to_input_list returns messages');
push @$copy, { role => 'assistant', content => 'next' };
is(scalar @{ $result->messages }, 1, 'to_input_list returns shallow copy');

done_testing;
