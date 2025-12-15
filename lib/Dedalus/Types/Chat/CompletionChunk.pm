package Dedalus::Types::Chat::CompletionChunk;
use Moo;
use Types::Standard qw(Str Int ArrayRef Maybe HashRef InstanceOf);

use Dedalus::Types::Chat::ChunkChoice;

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has object => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'chat.completion.chunk' },
);

has created => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has model => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has choices => (
    is      => 'ro',
    isa     => ArrayRef[InstanceOf['Dedalus::Types::Chat::ChunkChoice']],
    default => sub { [] },
);

has usage => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has system_fingerprint => (
    is  => 'ro',
    isa => Maybe[Str],
);

has service_tier => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @choices = map { Dedalus::Types::Chat::ChunkChoice->from_hash($_) } @{ $hash->{choices} || [] };
    return $class->new(
        id                 => $hash->{id},
        object             => $hash->{object} // 'chat.completion.chunk',
        created            => $hash->{created} // time,
        model              => $hash->{model} // '',
        choices            => \@choices,
        usage              => $hash->{usage},
        system_fingerprint => $hash->{system_fingerprint},
        service_tier       => $hash->{service_tier},
    );
}

1;
