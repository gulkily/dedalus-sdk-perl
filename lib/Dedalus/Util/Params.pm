package Dedalus::Util::Params;
use strict;
use warnings;

use Exporter 'import';
use Carp qw(croak);
use Scalar::Util qw(reftype);

our @EXPORT_OK = qw(require_params ensure_arrayref deep_copy);

sub require_params {
    my ($params, @keys) = @_;
    croak 'params must be hashref' unless ref $params eq 'HASH';
    for my $k (@keys) {
        next if exists $params->{$k};
        croak "$k is required";
    }
    return $params;
}

sub ensure_arrayref {
    my ($value, $field) = @_;
    $field ||= 'value';
    return $value if ref $value eq 'ARRAY';
    if (!ref $value) {
        return [ $value ];
    }
    croak "$field must be an array reference or scalar";
}

sub deep_copy {
    my ($value) = @_;
    my $type = reftype($value) || '';
    if ($type eq 'HASH') {
        my %copy;
        for my $k (keys %$value) {
            $copy{$k} = deep_copy($value->{$k});
        }
        return \%copy;
    } elsif ($type eq 'ARRAY') {
        return [ map { deep_copy($_) } @$value ];
    }
    return $value;
}

1;
