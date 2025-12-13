package Dedalus::Stream;
use Moo;
use Types::Standard qw(ArrayRef Bool Maybe);
use AnyEvent;

has queue => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
);

has finished => (
    is      => 'rw',
    isa     => Bool,
    default => sub { 0 },
);

has guard => (
    is => 'rw',
);

sub next {
    my ($self) = @_;
    while (!@{ $self->queue }) {
        return undef if $self->finished;
        AnyEvent->one_event;
    }
    return shift @{ $self->queue };
}

sub push_chunk {
    my ($self, $chunk) = @_;
    push @{ $self->queue }, $chunk if defined $chunk;
}

sub finish {
    my ($self) = @_;
    $self->finished(1);
}

sub all {
    my ($self) = @_;
    return @{ $self->queue };
}

sub reset {
    my ($self) = @_;
    @{ $self->queue } = ();
}

sub to_arrayref {
    my ($self) = @_;
    return [ $self->all ];
}

1;
