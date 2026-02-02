package Dedalus::Types::Shared::DedalusModel;
use Moo;
use Types::Standard qw(Str Maybe InstanceOf HashRef);

use Dedalus::Types::Shared::Settings;

has model => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has settings => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Shared::Settings']],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $settings = Dedalus::Types::Shared::Settings->from_hash($hash->{settings});
    return $class->new(
        model    => $hash->{model},
        settings => $settings,
        raw      => $hash,
    );
}

1;
