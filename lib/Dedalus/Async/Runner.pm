package Dedalus::Async::Runner;
use strict;
use warnings;
use Carp qw(croak);
use Cpanel::JSON::XS qw(encode_json decode_json);
use Scalar::Util qw(blessed);
use Sub::Util qw(subname);
use Future;

use Dedalus::Types::Runner::RunResult;
use Dedalus::Types::Runner::ToolResult;

sub new {
    my ($class, %args) = @_;
    my $client = $args{client};
    croak 'client is required' unless $client;
    return bless { client => $client, verbose => $args{verbose} // 0 }, $class;
}

sub run {
    my ($self, %args) = @_;
    my $model = $args{model};
    croak 'model is required' unless defined $model && $model ne '';
    if ($args{stream}) {
        croak 'streaming runner is not yet supported';
    }

    my $messages = _build_messages(\%args);
    my ($tool_schemas, $tool_handlers) = _prepare_tools($args{tools});

    my $state = {
        messages     => $messages,
        tool_schemas => $tool_schemas,
        tool_handlers => $tool_handlers,
        tool_results => [],
        tools_called => [],
        steps_used   => 0,
        max_steps    => $args{max_steps} // 10,
        final_output => undef,
        args         => \%args,
    };

    return _run_step($self, $state);
}

sub _run_step {
    my ($self, $state) = @_;
    if ($state->{steps_used} >= $state->{max_steps}) {
        return Future->done(_build_result($state));
    }

    $state->{steps_used}++;
    my %params = (
        model    => $state->{args}->{model},
        messages => $state->{messages},
    );
    for my $field (qw(temperature max_tokens top_p frequency_penalty presence_penalty logit_bias response_format tool_choice)) {
        $params{$field} = $state->{args}->{$field} if defined $state->{args}->{$field};
    }
    if ($state->{tool_schemas} && @{ $state->{tool_schemas} }) {
        $params{tools} = $state->{tool_schemas};
    }

    my $future = $self->{client}->chat->completions->create(%params);
    return $future->then(sub {
        my ($completion) = @_;
        my $choice = ($completion->choices || [])->[0];
        return Future->done(_build_result($state)) unless $choice;

        my $message = $choice->message;
        $state->{final_output} = _stringify_content($message->content);

        my $assistant_msg = { role => 'assistant', content => $message->content };
        if ($message->tool_calls && @{ $message->tool_calls }) {
            my @raw_calls = map { $_->raw } @{ $message->tool_calls };
            $assistant_msg->{tool_calls} = \@raw_calls;
        }
        push @{ $state->{messages} }, $assistant_msg;

        my $tool_calls = $message->tool_calls;
        return Future->done(_build_result($state)) unless $tool_calls && @$tool_calls;

        my @queue = @$tool_calls;
        my $process_next;
        $process_next = sub {
            my $call = shift @queue;
            return Future->done(1) unless $call;
            return _execute_tool_call($state, $call)->then(sub { $process_next->() });
        };

        return $process_next->()->then(sub { _run_step($self, $state) });
    });
}

sub _execute_tool_call {
    my ($state, $call) = @_;
    my $fn = $call->function || {};
    my $name = $fn->{name};
    push @{ $state->{tools_called} }, $name if defined $name;
    my $args_hash = _parse_args($fn->{arguments});

    my $handler = (defined $name) ? $state->{tool_handlers}{$name} : undef;
    if (!$handler) {
        return _record_tool_result($state, $call, undef, defined $name ? "tool '$name' not found" : 'tool name missing');
    }

    my $result;
    my $error;
    eval {
        $result = $handler->(%$args_hash);
        1;
    } or do {
        $error = $@ || 'tool execution failed';
    };

    if (!$error && blessed($result) && $result->isa('Future')) {
        return $result->then(
            sub {
                my ($value) = @_;
                _record_tool_result($state, $call, $value, undef);
            },
            sub {
                my ($err) = @_;
                _record_tool_result($state, $call, undef, $err);
            }
        );
    }

    return _record_tool_result($state, $call, $result, $error);
}

sub _record_tool_result {
    my ($state, $call, $result, $error) = @_;
    my $name = $call->function ? $call->function->{name} : undef;
    my $tool_result = Dedalus::Types::Runner::ToolResult->new(
        name   => $name,
        result => $result,
        step   => $state->{steps_used},
        error  => $error,
        raw    => {
            name   => $name,
            result => $result,
            step   => $state->{steps_used},
            error  => $error,
        },
    );
    push @{ $state->{tool_results} }, $tool_result;
    my $content = defined $error ? $error : _stringify_content($result);
    push @{ $state->{messages} }, {
        role         => 'tool',
        tool_call_id => $call->id,
        content      => $content,
    };
    return Future->done($tool_result);
}

sub _build_result {
    my ($state) = @_;
    my $raw = {
        final_output => $state->{final_output},
        tool_results => [ map { $_->raw } @{ $state->{tool_results} } ],
        steps_used   => $state->{steps_used},
        tools_called => $state->{tools_called},
        messages     => $state->{messages},
        intents      => $state->{args}->{return_intent} ? [] : undef,
    };

    return Dedalus::Types::Runner::RunResult->new(
        final_output => $state->{final_output},
        output       => $state->{final_output},
        content      => $state->{final_output},
        tool_results => $state->{tool_results},
        steps_used   => $state->{steps_used},
        tools_called => $state->{tools_called},
        messages     => $state->{messages},
        intents      => $state->{args}->{return_intent} ? [] : undef,
        raw          => $raw,
    );
}

sub _build_messages {
    my ($args) = @_;
    my $messages = [];
    if ($args->{messages} && ref $args->{messages} eq 'ARRAY') {
        $messages = [ @{ $args->{messages} } ];
    } elsif (defined $args->{input}) {
        $messages = [ { role => 'user', content => $args->{input} } ];
    }

    if (defined $args->{instructions} && $args->{instructions} ne '') {
        unshift @$messages, { role => 'system', content => $args->{instructions} };
    }

    return $messages;
}

sub _prepare_tools {
    my ($tools) = @_;
    return (undef, {}) unless $tools && ref $tools eq 'ARRAY' && @$tools;

    my @schemas;
    my %handlers;
    my $idx = 0;

    for my $tool (@$tools) {
        if (ref $tool eq 'CODE') {
            $idx++;
            my $name = subname($tool) || "tool_$idx";
            $handlers{$name} = $tool;
            push @schemas, {
                type     => 'function',
                function => {
                    name        => $name,
                    description => undef,
                    parameters  => { type => 'object', properties => {}, required => [] },
                },
            };
            next;
        }

        if (ref $tool eq 'HASH') {
            my $handler = $tool->{handler};
            croak 'tool handler must be a coderef' if defined $handler && ref $handler ne 'CODE';
            my $schema;
            if ($tool->{schema} && ref $tool->{schema} eq 'HASH') {
                $schema = $tool->{schema};
            } elsif ($tool->{function} && ref $tool->{function} eq 'HASH') {
                $schema = $tool->{function};
            } else {
                $schema = {
                    name        => $tool->{name},
                    description => $tool->{description},
                    parameters  => $tool->{parameters} || { type => 'object', properties => {}, required => [] },
                };
            }
            my $name = $schema->{name} || $tool->{name};
            croak 'tool name is required' unless defined $name && $name ne '';
            $handlers{$name} = $handler if $handler;
            push @schemas, {
                type     => $tool->{type} || 'function',
                function => $schema,
            };
            next;
        }

        croak 'tools must be coderefs or hash refs';
    }

    return (\@schemas, \%handlers);
}

sub _parse_args {
    my ($raw) = @_;
    return {} unless defined $raw && $raw ne '';
    return $raw if ref $raw eq 'HASH';
    my $decoded;
    eval { $decoded = decode_json($raw); 1 } or return {};
    return ref $decoded eq 'HASH' ? $decoded : {};
}

sub _stringify_content {
    my ($value) = @_;
    return '' unless defined $value;
    return $value if !ref $value;
    return encode_json($value);
}

1;
