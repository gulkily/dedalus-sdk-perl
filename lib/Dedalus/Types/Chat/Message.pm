package Dedalus::Types::Chat::Message;
use Moo;
use Types::Standard qw(Str Any);

has role => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has content => (
    is       => 'ro',
    isa      => Any,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    return $class->new(
      role    => $hash->{role} // 'assistant',
      content => $hash->{content},
    );
}

1;
