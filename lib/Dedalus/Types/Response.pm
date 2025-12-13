package Dedalus::Types::Response;
use Moo;
use Types::Standard qw(Str Int Maybe ArrayRef HashRef);

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has object => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'response' },
);

has model => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has status => (
    is  => 'ro',
    isa => Maybe[Str],
);

has created => (
    is  => 'ro',
    isa => Maybe[Int],
);

has output => (
    is  => 'ro',
    isa => Maybe[ArrayRef],
);

has metadata => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has usage => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        id       => $hash->{id},
        object   => $hash->{object} // 'response',
        model    => $hash->{model} // '',
        status   => $hash->{status},
        created  => $hash->{created} // $hash->{created_at},
        output   => $hash->{output},
        metadata => $hash->{metadata},
        usage    => $hash->{usage},
    );
}

1;
