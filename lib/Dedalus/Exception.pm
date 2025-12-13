package Dedalus::Exception;
use Moo;

has message => (
    is      => 'ro',
    default => sub { 'Dedalus API error' },
);

has http_status => (
    is => 'ro',
);

has body => (
    is => 'ro',
);

use overload '""' => sub { shift->message }, fallback => 1;

1;
