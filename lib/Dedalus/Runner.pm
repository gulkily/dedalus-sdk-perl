package Dedalus::Runner;
use strict;
use warnings;
use Carp qw(croak);
use Cpanel::JSON::XS qw(encode_json decode_json);
use Sub::Util qw(subname);

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

    my @tool_results;
    my @tools_called;
    my $steps_used = 0;
    my $final_output;

    while ($steps_used < ($args{max_steps} // 10)) {
        $steps_used++;
        my %params = (
            model    => $model,
            messages => $messages,
        );
        $params{temperature}       = $args{temperature} if defined $args{temperature};
        $params{max_tokens}        = $args{max_tokens} if defined $args{max_tokens};
        $params{top_p}             = $args{top_p} if defined $args{top_p};
        $params{frequency_penalty} = $args{frequency_penalty} if defined $args{frequency_penalty};
        $params{presence_penalty}  = $args{presence_penalty} if defined $args{presence_penalty};
        $params{logit_bias}        = $args{logit_bias} if defined $args{logit_bias};
        $params{response_format}   = $args{response_format} if defined $args{response_format};
        $params{tool_choice}       = $args{tool_choice} if defined $args{tool_choice};
        $params{tools}             = $tool_schemas if $tool_schemas && @$tool_schemas;

        my $completion = $self->{client}->chat->completions->create(%params);
        my $choice = ($completion->choices || [])->[0];
        last unless $choice;

        my $message = $choice->message;
        $final_output = _stringify_content($message->content);

        my $assistant_msg = { role => 'assistant', content => $message->content };
        if ($message->tool_calls && @{ $message->tool_calls }) {
            my @raw_calls = map { $_->raw } @{ $message->tool_calls };
            $assistant_msg->{tool_calls} = \@raw_calls;
        }
        push @$messages, $assistant_msg;

        my $tool_calls = $message->tool_calls;
        last unless $tool_calls && @$tool_calls;

        for my $call (@$tool_calls) {
            my $fn = $call->function || {};
            my $name = $fn->{name};
            push @tools_called, $name if defined $name;
            my $args_hash = _parse_args($fn->{arguments});
            my ($result, $error);
            if (defined $name && exists $tool_handlers->{$name} && $tool_handlers->{$name}) {
                eval {
                    $result = $tool_handlers->{$name}->(%$args_hash);
                    1;
                } or do {
                    $error = $@ || 'tool execution failed';
                };
            } else {
                $error = defined $name ? "tool '$name' not found" : 'tool name missing';
            }

            my $tool_result = Dedalus::Types::Runner::ToolResult->new(
                name   => $name,
                result => $result,
                step   => $steps_used,
                error  => $error,
                raw    => {
                    name   => $name,
                    result => $result,
                    step   => $steps_used,
                    error  => $error,
                },
            );
            push @tool_results, $tool_result;

            my $content = defined $error ? $error : _stringify_content($result);
            push @$messages, {
                role         => 'tool',
                tool_call_id => $call->id,
                content      => $content,
            };
        }
    }

    my $raw = {
        final_output => $final_output,
        tool_results => [ map { $_->raw } @tool_results ],
        steps_used   => $steps_used,
        tools_called => \@tools_called,
        messages     => $messages,
        intents      => $args{return_intent} ? [] : undef,
    };

    return Dedalus::Types::Runner::RunResult->new(
        final_output => $final_output,
        output       => $final_output,
        content      => $final_output,
        tool_results => \@tool_results,
        steps_used   => $steps_used,
        tools_called => \@tools_called,
        messages     => $messages,
        intents      => $args{return_intent} ? [] : undef,
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
