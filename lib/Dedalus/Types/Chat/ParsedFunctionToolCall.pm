package Dedalus::Types::Chat::ParsedFunction;
use Moo;
use Types::Standard qw(Maybe Str Any HashRef);

has name => (
    is  => 'ro',
    isa => Maybe[Str],
);

has arguments => (
    is  => 'ro',
    isa => Maybe[Str],
);

has parsed_arguments => (
    is  => 'ro',
    isa => Maybe[Any],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        name            => $hash->{name},
        arguments       => $hash->{arguments},
        parsed_arguments => $hash->{parsed_arguments},
        raw             => $hash,
    );
}

1;

package Dedalus::Types::Chat::ParsedFunctionToolCall;
use Moo;
use Types::Standard qw(Maybe Str InstanceOf HashRef);

has id => (
    is  => 'ro',
    isa => Maybe[Str],
);

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'function' },
);

has function => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Chat::ParsedFunction']],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $function;
    if (exists $hash->{function} && ref $hash->{function} eq 'HASH') {
        $function = Dedalus::Types::Chat::ParsedFunction->from_hash($hash->{function});
    }
    return $class->new(
        id       => $hash->{id},
        type     => $hash->{type} // 'function',
        function => $function,
        raw      => $hash,
    );
}

1;
