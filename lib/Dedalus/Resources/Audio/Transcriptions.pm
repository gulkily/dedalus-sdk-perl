package Dedalus::Resources::Audio::Transcriptions;
use Moo;
use Carp qw(croak);
use File::Basename qw(basename);

use Dedalus::Types::Audio::TranscriptionCreateResponse;

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    croak 'file is required' unless $params{file};
    croak 'model is required' unless $params{model};

    my $file = $params{file};
    my ($filename, $content, $content_type);

    if (ref $file eq 'ARRAY') {
        ($filename, $content, $content_type) = @$file;
    } elsif (ref $file eq 'SCALAR') {
        $content = $$file;
        $filename = 'upload.wav';
    } else {
        $filename = basename($file);
        open my $fh, '<', $file or die "unable to open $file: $!";
        binmode $fh;
        local $/;
        $content = <$fh>;
        close $fh;
    }

    require Digest::MD5;
    my $boundary = 'DedalusBoundary' . Digest::MD5::md5_hex(rand() . $$);
    my $body = _build_multipart($boundary, {
        file  => { filename => $filename, content => $content, content_type => $content_type // 'application/octet-stream' },
        model => $params{model},
        (language        => $params{language})        x !!$params{language},
        (prompt          => $params{prompt})          x !!$params{prompt},
        (response_format => $params{response_format}) x !!$params{response_format},
        (temperature     => $params{temperature})     x defined $params{temperature},
    });

    my $response = $self->client->request(
        'POST',
        '/v1/audio/transcriptions',
        headers => {
            'Content-Type' => "multipart/form-data; boundary=$boundary",
        },
        content => $body,
    );

    my $data = $response->{data} || {};
    return Dedalus::Types::Audio::TranscriptionCreateResponse->from_hash($data);
}

sub _build_multipart {
    my ($boundary, $fields) = @_;
    my @parts;
    for my $key (keys %$fields) {
        my $value = $fields->{$key};
        if (ref $value eq 'HASH' && exists $value->{content}) {
            push @parts,
              "--$boundary\r\n"
              . "Content-Disposition: form-data; name=\"$key\"; filename=\"$value->{filename}\"\r\n"
              . "Content-Type: $value->{content_type}\r\n\r\n$value->{content}\r\n";
        } else {
            push @parts,
              "--$boundary\r\n"
              . "Content-Disposition: form-data; name=\"$key\"\r\n\r\n$value\r\n";
        }
    }
    push @parts, "--$boundary--\r\n";
    return join '', @parts;
}

1;
