package Dedalus::Stream;
use Moo;
use Types::Standard qw(ArrayRef Bool);
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

has cv => (
    is      => 'rw',
);

has guard => (
    is => 'rw',
);

sub next {
    my ($self) = @_;
    while (1) {
        if (@{ $self->queue }) {
            return shift @{ $self->queue };
        }
        return undef if $self->finished;
        my $cv = AnyEvent->condvar;
        $self->cv($cv);
        $cv->recv;
    }
}

sub push_chunk {
    my ($self, $chunk) = @_;
    return unless defined $chunk;
    push @{ $self->queue }, $chunk;
    if (my $cv = $self->cv) {
        $self->cv(undef);
        $cv->send;
    }
}

sub finish {
    my ($self) = @_;
    $self->finished(1);
    if (my $cv = $self->cv) {
        $self->cv(undef);
        $cv->send;
    }
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
