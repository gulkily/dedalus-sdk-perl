package Dedalus::Util::QS;
use strict;
use warnings;

use Exporter 'import';
use URI::Escape qw(uri_escape_utf8);
use Scalar::Util qw(blessed);
use Carp qw(croak);

our @EXPORT_OK = qw(stringify stringify_items);

my $DEFAULT;

sub new {
    my ($class, %opts) = @_;
    my $array_format  = $opts{array_format}  // 'repeat';
    my $nested_format = $opts{nested_format} // 'brackets';
    return bless {
        array_format  => $array_format,
        nested_format => $nested_format,
    }, $class;
}

sub stringify {
    my ($self, @rest) = @_;
    if (blessed($self) && $self->isa(__PACKAGE__)) {
        return $self->_stringify(@rest);
    }
    if (!ref($self) && $self eq __PACKAGE__) {
        $DEFAULT ||= __PACKAGE__->new;
        return $DEFAULT->_stringify(@rest);
    }
    $DEFAULT ||= __PACKAGE__->new;
    return $DEFAULT->_stringify($self, @rest);
}

sub stringify_items {
    my ($self, @rest) = @_;
    if (blessed($self) && $self->isa(__PACKAGE__)) {
        return $self->_stringify_items(@rest);
    }
    if (!ref($self) && $self eq __PACKAGE__) {
        $DEFAULT ||= __PACKAGE__->new;
        return $DEFAULT->_stringify_items(@rest);
    }
    $DEFAULT ||= __PACKAGE__->new;
    return $DEFAULT->_stringify_items($self, @rest);
}

sub _stringify {
    my ($self, $params, %opts) = @_;
    return '' unless $params && ref $params eq 'HASH';
    my $items = $self->_stringify_items($params, %opts);
    return '' unless @$items;
    return join '&', map {
        _escape($_->[0]) . '=' . _escape($_->[1])
    } @$items;
}

sub _stringify_items {
    my ($self, $params, %opts) = @_;
    croak 'params must be hashref' unless ref $params eq 'HASH';
    my $array_format  = exists $opts{array_format}  ? $opts{array_format}  : $self->{array_format};
    my $nested_format = exists $opts{nested_format} ? $opts{nested_format} : $self->{nested_format};

    my @items;
    for my $key (sort keys %$params) {
        push @items, @{ _stringify_item($key, $params->{$key}, $array_format, $nested_format) };
    }
    return \@items;
}

sub _stringify_item {
    my ($key, $value, $array_format, $nested_format) = @_;
    my $ref = ref $value;
    if ($ref eq 'HASH') {
        my @items;
        for my $subkey (sort keys %$value) {
            my $nested_key = $nested_format eq 'dots'
                ? "$key.$subkey"
                : "$key\[$subkey\]";
            push @items, @{ _stringify_item($nested_key, $value->{$subkey}, $array_format, $nested_format) };
        }
        return \@items;
    }

    if ($ref eq 'ARRAY') {
        if ($array_format eq 'comma') {
            my @values;
            for my $item (@$value) {
                next unless defined $item;
                my $string = _primitive_value_to_str($item);
                push @values, $string if defined $string;
            }
            return [ [ $key, join(',', @values) ] ];
        }
        if ($array_format eq 'repeat') {
            my @items;
            for my $item (@$value) {
                push @items, @{ _stringify_item($key, $item, $array_format, $nested_format) };
            }
            return \@items;
        }
        if ($array_format eq 'indices') {
            croak 'The array indices format is not supported yet';
        }
        if ($array_format eq 'brackets') {
            my @items;
            my $bracket_key = $key . '[]';
            for my $item (@$value) {
                push @items, @{ _stringify_item($bracket_key, $item, $array_format, $nested_format) };
            }
            return \@items;
        }
        croak "Unknown array_format value: $array_format, choose from comma, repeat, indices, brackets";
    }

    my $string = _primitive_value_to_str($value);
    return [] unless defined $string && length $string;
    return [ [ $key, $string ] ];
}

sub _primitive_value_to_str {
    my ($value) = @_;
    return undef unless defined $value;
    if (_is_json_boolean($value)) {
        return $value ? 'true' : 'false';
    }
    return "$value";
}

sub _is_json_boolean {
    my ($value) = @_;
    return 0 unless blessed($value);
    return $value->isa('JSON::PP::Boolean')
        || $value->isa('JSON::XS::Boolean')
        || $value->isa('Cpanel::JSON::XS::Boolean');
}

sub _escape {
    my ($value) = @_;
    my $escaped = uri_escape_utf8($value);
    $escaped =~ s/%20/+/g;
    return $escaped;
}

1;
