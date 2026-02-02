package Dedalus::Types::Shared::SettingsReasoning;
use Moo;
use Types::Standard qw(Maybe Str);

has effort => (
    is  => 'ro',
    isa => Maybe[Str],
);

has generate_summary => (
    is  => 'ro',
    isa => Maybe[Str],
);

has summary => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    return undef unless $hash && ref $hash eq 'HASH';
    return $class->new(
        effort           => $hash->{effort},
        generate_summary => $hash->{generate_summary},
        summary          => $hash->{summary},
    );
}

1;
