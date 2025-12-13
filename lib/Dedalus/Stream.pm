package Dedalus::Stream;
use Moo;
use Types::Standard qw(ArrayRef);

has events => (
    is       => 'ro',
    isa      => ArrayRef,
    required => 1,
);

has _cursor => (
    is      => 'rw',
    default => sub { 0 },
);

sub next {
    my ($self) = @_;
    my $index = $self->_cursor;
    return undef if $index >= @{ $self->events };
    $self->_cursor($index + 1);
    return $self->events->[$index];
}

sub all {
    my ($self) = @_;
    return @{ $self->events };
}

sub reset {
    my ($self) = @_;
    $self->_cursor(0);
}

sub to_arrayref {
    my ($self) = @_;
    return [ $self->all ];
}

1;
