package Dedalus::Types::Runner::RunResult;
use Moo;
use Types::Standard qw(Int Maybe Str ArrayRef HashRef InstanceOf);

use Dedalus::Types::Runner::ToolResult;

has final_output => (
    is  => 'ro',
    isa => Maybe[Str],
);

has output => (
    is  => 'ro',
    isa => Maybe[Str],
);

has content => (
    is  => 'ro',
    isa => Maybe[Str],
);

has tool_results => (
    is      => 'ro',
    isa     => ArrayRef[InstanceOf['Dedalus::Types::Runner::ToolResult']],
    default => sub { [] },
);

has steps_used => (
    is  => 'ro',
    isa => Maybe[Int],
);

has tools_called => (
    is      => 'ro',
    isa     => ArrayRef[Str],
    default => sub { [] },
);

has messages => (
    is      => 'ro',
    isa     => ArrayRef[HashRef],
    default => sub { [] },
);

has intents => (
    is  => 'ro',
    isa => Maybe[ArrayRef],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @tool_results = map { Dedalus::Types::Runner::ToolResult->from_hash($_) }
        @{ $hash->{tool_results} || [] };
    my $final_output = $hash->{final_output};
    $final_output = $hash->{output}  if !defined $final_output && exists $hash->{output};
    $final_output = $hash->{content} if !defined $final_output && exists $hash->{content};

    return $class->new(
        final_output => $final_output,
        output       => $hash->{output},
        content      => $hash->{content},
        tool_results => \@tool_results,
        steps_used   => $hash->{steps_used},
        tools_called => $hash->{tools_called} || [],
        messages     => $hash->{messages} || [],
        intents      => $hash->{intents},
        raw          => $hash,
    );
}

sub to_input_list {
    my ($self) = @_;
    return [ @{ $self->messages } ];
}

1;
