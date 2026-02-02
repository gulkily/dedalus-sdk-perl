package Dedalus::Util::Files;
use strict;
use warnings;

use Exporter 'import';
use Scalar::Util qw(blessed openhandle);
use Carp qw(croak);

our @EXPORT_OK = qw(extract_files);

sub extract_files {
    my ($query, %opts) = @_;
    croak 'query must be hashref' unless ref $query eq 'HASH';
    my $paths = $opts{paths} || [];
    my @files;
    for my $path (@$paths) {
        next unless ref $path eq 'ARRAY';
        push @files, @{ _extract_items($query, $path, 0, undef) };
    }
    return \@files;
}

sub _extract_items {
    my ($obj, $path, $index, $flattened_key) = @_;
    if ($index >= @$path) {
        return [] unless defined $obj;
        if (ref $obj eq 'ARRAY') {
            my @files;
            for my $entry (@$obj) {
                _assert_is_file_content($entry, $flattened_key ? $flattened_key . '[]' : '');
                push @files, [ $flattened_key . '[]', $entry ];
            }
            return \@files;
        }
        _assert_is_file_content($obj, $flattened_key);
        return [ [ $flattened_key, $obj ] ];
    }

    my $key = $path->[$index];
    $index++;

    if (ref $obj eq 'HASH') {
        return [] unless exists $obj->{$key};
        my $item;
        if ($index == @$path) {
            $item = delete $obj->{$key};
        } else {
            $item = $obj->{$key};
        }
        my $new_key = defined $flattened_key ? "$flattened_key\[$key\]" : $key;
        return _extract_items($item, $path, $index, $new_key);
    }

    if (ref $obj eq 'ARRAY') {
        return [] unless $key eq '<array>';
        my @files;
        my $new_key = defined $flattened_key ? $flattened_key . '[]' : '[]';
        for my $entry (@$obj) {
            push @files, @{ _extract_items($entry, $path, $index, $new_key) };
        }
        return \@files;
    }

    return [];
}

sub _assert_is_file_content {
    my ($obj, $key) = @_;
    return if _is_file_content($obj);
    my $target = defined $key && length $key ? "entry at `$key`" : "file input";
    croak "Expected $target to be file content";
}

sub _is_file_content {
    my ($obj) = @_;
    return 0 unless defined $obj;
    return 1 unless ref $obj;
    return 1 if ref $obj eq 'SCALAR';
    return 1 if ref $obj eq 'ARRAY';
    if (ref $obj eq 'HASH') {
        return 1 if exists $obj->{content} || exists $obj->{path} || exists $obj->{handle};
        return 0;
    }
    return 1 if openhandle($obj);
    return 1 if blessed($obj) && $obj->isa('Dedalus::FileUpload');
    return 1 if blessed($obj) && $obj->can('slurp_raw');
    return 0;
}

1;
