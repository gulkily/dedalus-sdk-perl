package Dedalus::Types::Chat::Completion;
use Moo;
use Types::Standard qw(Str ArrayRef Maybe InstanceOf);
use Dedalus::Types::Chat::Choice;
use Dedalus::Types::Chat::Usage;

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has object => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'chat.completion' },
);

has model => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has created => (
    is  => 'ro',
    isa => Maybe[Str],
);

has service_tier => (
    is  => 'ro',
    isa => Maybe[Str],
);

has system_fingerprint => (
    is  => 'ro',
    isa => Maybe[Str],
);

has choices => (
    is      => 'ro',
    isa     => ArrayRef[InstanceOf['Dedalus::Types::Chat::Choice']],
    default => sub { [] },
);

has usage => (
    is      => 'ro',
    isa     => InstanceOf['Dedalus::Types::Chat::Usage'],
    default => sub { Dedalus::Types::Chat::Usage->new },
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @choices = map { Dedalus::Types::Chat::Choice->from_hash($_) } @{ $hash->{choices} || [] };
    my $usage = Dedalus::Types::Chat::Usage->from_hash($hash->{usage});

    return $class->new(
        id      => $hash->{id},
        object  => $hash->{object} // 'chat.completion',
        model   => $hash->{model} // '',
        created => $hash->{created},
        service_tier     => $hash->{service_tier},
        system_fingerprint => $hash->{system_fingerprint},
        choices => \@choices,
        usage   => $usage,
    );
}

1;
