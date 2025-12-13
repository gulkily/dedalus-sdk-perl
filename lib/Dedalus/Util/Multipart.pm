package Dedalus::Util::Multipart;
use strict;
use warnings;

use Exporter 'import';
use Digest::MD5 qw(md5_hex);
use File::Basename qw(basename);

our @EXPORT_OK = qw(normalize_file_field build_multipart_body);

sub normalize_file_field {
    my ($value, $default_filename, $default_type) = @_;
    my ($filename, $content, $content_type);

    if (ref $value eq 'HASH' && exists $value->{content}) {
        $filename     = $value->{filename};
        $content      = $value->{content};
        $content_type = $value->{content_type};
    } elsif (ref $value eq 'ARRAY') {
        ($filename, $content, $content_type) = @$value;
    } elsif (ref $value eq 'SCALAR') {
        $content  = $$value;
        $filename = $default_filename || 'upload.dat';
    } else {
        $filename = basename($value);
        open my $fh, '<', $value or die "unable to open $value: $!";
        binmode $fh;
        local $/;
        $content = <$fh>;
        close $fh;
    }

    $filename     ||= $default_filename || 'upload.dat';
    $content_type ||= $default_type     || 'application/octet-stream';

    return {
        filename     => $filename,
        content      => $content,
        content_type => $content_type,
    };
}

sub build_multipart_body {
    my ($fields) = @_;
    my $boundary = 'DedalusBoundary' . md5_hex(rand() . $$ . {});
    my @parts;

    for my $key (keys %$fields) {
        my $val = $fields->{$key};
        next unless defined $val;
        if (ref $val eq 'HASH' && exists $val->{content}) {
            push @parts,
              "--$boundary\r\n"
              . "Content-Disposition: form-data; name=\"$key\"; filename=\"$val->{filename}\"\r\n"
              . "Content-Type: $val->{content_type}\r\n\r\n$val->{content}\r\n";
        } else {
            push @parts,
              "--$boundary\r\n"
              . "Content-Disposition: form-data; name=\"$key\"\r\n\r\n$val\r\n";
        }
    }

    push @parts, "--$boundary--\r\n";
    return ($boundary, join('', @parts));
}

1;
