package Dedalus::Types::Chat::Choice;
use Moo;
use Types::Standard qw(Int Maybe Str InstanceOf);
use Dedalus::Types::Chat::Message;

has index => (
    is      => 'ro',
    isa     => Int,
    default => sub { 0 },
);

has finish_reason => (
    is  => 'ro',
    isa => Maybe[Str],
);

has message => (
    is       => 'ro',
    isa      => InstanceOf['Dedalus::Types::Chat::Message'],
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $message = $hash->{message} || {};
    return $class->new(
        index         => $hash->{index} // 0,
        finish_reason => $hash->{finish_reason},
        message       => Dedalus::Types::Chat::Message->from_hash($message),
    );
}

1;
