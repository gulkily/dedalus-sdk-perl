package Dedalus::Types::Model;
use Moo;
use Types::Standard qw(Str Maybe HashRef ArrayRef InstanceOf);

use Dedalus::Types::Model::Capabilities;
use Dedalus::Types::Model::Defaults;

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has created_at => (
    is  => 'ro',
    isa => Str,
);

has provider => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has capabilities => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Model::Capabilities']],
);

has defaults => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Model::Defaults']],
);

has description => (is => 'ro', isa => Maybe[Str]);
has display_name => (is => 'ro', isa => Maybe[Str]);
has provider_declared_generation_methods => (is => 'ro', isa => Maybe[ArrayRef[Str]]);
has provider_info => (is => 'ro', isa => Maybe[HashRef]);
has version => (is => 'ro', isa => Maybe[Str]);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';

    my $capabilities = Dedalus::Types::Model::Capabilities->from_hash($hash->{capabilities});
    my $defaults     = Dedalus::Types::Model::Defaults->from_hash($hash->{defaults});

    return $class->new(
        id        => $hash->{id},
        created_at => $hash->{created_at} // '',
        provider  => $hash->{provider} // '',
        capabilities => $capabilities,
        defaults     => $defaults,
        description  => $hash->{description},
        display_name => $hash->{display_name},
        provider_declared_generation_methods => $hash->{provider_declared_generation_methods},
        provider_info => $hash->{provider_info},
        version       => $hash->{version},
    );
}

1;
