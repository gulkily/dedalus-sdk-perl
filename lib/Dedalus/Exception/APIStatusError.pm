package Dedalus::Exception::APIStatusError;
use Moo;
extends 'Dedalus::Exception::APIError';

has headers => (
    is => 'ro',
);

1;
