package Dedalus::Types::FileObject;
use Moo;
use Types::Standard qw(Str Int Maybe HashRef Bool);

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has object => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'file' },
);

has bytes => (
    is  => 'ro',
    isa => Maybe[Int],
);

has created_at => (
    is  => 'ro',
    isa => Maybe[Int],
);

has filename => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has purpose => (
    is  => 'ro',
    isa => Maybe[Str],
);

has status => (
    is  => 'ro',
    isa => Maybe[Str],
);

has status_details => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has metadata => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has deleted => (
    is  => 'ro',
    isa => Maybe[Bool],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
        id             => $hash->{id},
        object         => $hash->{object} // 'file',
        bytes          => $hash->{bytes},
        created_at     => $hash->{created} // $hash->{created_at},
        filename       => $hash->{filename} // '',
        purpose        => $hash->{purpose},
        status         => $hash->{status},
        status_details => $hash->{status_details},
        metadata       => $hash->{metadata},
        deleted        => $hash->{deleted},
    );
}

1;
