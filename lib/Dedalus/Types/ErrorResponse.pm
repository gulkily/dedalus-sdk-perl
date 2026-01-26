package Dedalus::Types::ErrorResponse;
use Moo;
use Types::Standard qw(HashRef Maybe Str);

has error => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has message => (
    is  => 'ro',
    isa => Maybe[Str],
);

has type => (
    is  => 'ro',
    isa => Maybe[Str],
);

has code => (
    is  => 'ro',
    isa => Maybe[Str],
);

has param => (
    is  => 'ro',
    isa => Maybe[Str],
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $error = {};
    if (exists $hash->{error} && ref $hash->{error} eq 'HASH') {
        $error = $hash->{error};
    }
    return $class->new(
        error   => $error,
        message => $error->{message},
        type    => $error->{type},
        code    => $error->{code},
        param   => $error->{param},
    );
}

1;
