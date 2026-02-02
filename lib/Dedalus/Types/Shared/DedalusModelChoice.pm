package Dedalus::Types::Shared::DedalusModelChoice;
use strict;
use warnings;
use Scalar::Util qw(blessed);

use Dedalus::Types::Shared::DedalusModel;

sub from_value {
    my ($class, $value) = @_;
    return undef unless defined $value;
    if (blessed($value) && $value->isa('Dedalus::Types::Shared::DedalusModel')) {
        return $value;
    }
    if (ref $value eq 'HASH') {
        return Dedalus::Types::Shared::DedalusModel->from_hash($value);
    }
    return $value;
}

1;
