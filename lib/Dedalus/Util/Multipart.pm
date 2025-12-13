package Dedalus::Util::Multipart;
use strict;
use warnings;

use Exporter 'import';
use Digest::MD5 qw(md5_hex);
use File::Basename qw(basename);
use Scalar::Util qw(blessed openhandle reftype);
use Carp qw(croak);
use Cpanel::JSON::XS qw(encode_json);

use Dedalus::FileUpload ();
use Dedalus::Util::MIME qw(guess_content_type);

our @EXPORT_OK = qw(normalize_file_field build_multipart_body);

sub normalize_file_field {
    my ($value, $default_filename, $default_type) = @_;
    my ($filename, $content, $content_type);

    if (blessed($value) && $value->isa('Dedalus::FileUpload')) {
        return $value->to_field(
            default_filename      => $default_filename,
            default_content_type  => $default_type,
        );
    }

    if (ref $value eq 'HASH') {
        if (exists $value->{content}) {
            $filename     = $value->{filename};
            $content      = $value->{content};
            $content_type = $value->{content_type};
        } elsif (my $path = $value->{path}) {
            $filename     = $value->{filename} || basename($path);
            $content      = _slurp_path($path);
            $content_type = $value->{content_type};
        } elsif (my $handle = $value->{handle}) {
            croak 'handle must be an open filehandle' unless openhandle($handle);
            $filename     = $value->{filename};
            $content      = _slurp_handle($handle);
            $content_type = $value->{content_type};
        } else {
            croak 'file hash must include content, path, or handle';
        }
    } elsif (ref $value eq 'ARRAY') {
        ($filename, $content, $content_type) = @$value;
    } elsif (ref $value eq 'SCALAR') {
        $content  = $$value;
        $filename = $default_filename || 'upload.dat';
    } elsif (my $handle = _maybe_handle($value)) {
        $content  = _slurp_handle($handle);
        $filename = $default_filename || 'upload.dat';
    } elsif (blessed($value) && $value->can('slurp_raw')) {
        $content  = $value->slurp_raw;
        $filename = $default_filename || 'upload.dat';
    } else {
        $filename = basename($value);
        $content  = _slurp_path($value);
    }

    $filename     ||= $default_filename || 'upload.dat';
    $content_type ||= $default_type     || guess_content_type($filename) || 'application/octet-stream';

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
            my $string = _stringify_field($val);
            push @parts,
              "--$boundary\r\n"
              . "Content-Disposition: form-data; name=\"$key\"\r\n\r\n$string\r\n";
        }
    }

    push @parts, "--$boundary--\r\n";
    return ($boundary, join('', @parts));
}

sub _slurp_path {
    my ($path) = @_;
    open my $fh, '<', $path or croak "unable to open $path: $!";
    binmode $fh;
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub _maybe_handle {
    my ($value) = @_;
    return $value if openhandle($value);
    return;
}

sub _slurp_handle {
    my ($handle) = @_;
    croak 'handle must be open' unless openhandle($handle);
    binmode $handle;
    my $pos = eval { tell($handle) };
    seek($handle, 0, 0) if defined $pos && $pos >= 0;
    local $/;
    my $content = <$handle>;
    seek($handle, $pos, 0) if defined $pos && $pos >= 0;
    return $content;
}

sub _stringify_field {
    my ($value) = @_;
    return '' unless defined $value;
    my $ref = ref $value;
    if ($ref && ($ref eq 'ARRAY' || $ref eq 'HASH')) {
        return encode_json($value);
    }
    return $value;
}

1;
