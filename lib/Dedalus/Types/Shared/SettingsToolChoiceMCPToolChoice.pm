package Dedalus::Types::Shared::SettingsToolChoiceMCPToolChoice;
use Moo;
use Types::Standard qw(Str);

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has server_label => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    return undef unless $hash && ref $hash eq 'HASH';
    return $class->new(
        name         => $hash->{name},
        server_label => $hash->{server_label},
    );
}

1;
