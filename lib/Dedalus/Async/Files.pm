package Dedalus::Async::Files;
use Moo;
use Future;
use Carp qw(croak);

use Dedalus::Async::Files::Content;
use Dedalus::Types::FileObject;
use Dedalus::Types::ListFilesResponse;
use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);

has client => (
    is       => 'ro',
    required => 1,
);

has content => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_content',
);

sub _build_content {
    my ($self) = @_;
    return Dedalus::Async::Files::Content->new(client => $self->client);
}

sub list {
    my ($self, %opts) = @_;
    my $future = $self->client->request_future('GET', '/v1/files', %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::ListFilesResponse->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

sub retrieve {
    my ($self, $file_id, %opts) = @_;
    croak 'file_id is required' unless $file_id;
    my $future = $self->client->request_future('GET', "/v1/files/$file_id", %opts);
    return $future->then(sub {
        my ($res) = @_;
        my $file = Dedalus::Types::FileObject->from_hash($res->{data} || {});
        Future->done($file);
    });
}

sub upload {
    my ($self, %params) = @_;
    croak 'purpose is required' unless $params{purpose};
    croak 'file is required'    unless $params{file};

    my %fields = (
        purpose => $params{purpose},
        file    => normalize_file_field($params{file}, 'upload.dat', 'application/octet-stream'),
    );
    $fields{metadata} = $params{metadata} if $params{metadata};

    my ($boundary, $body) = build_multipart_body(\%fields);
    my $future = $self->client->request_future(
        'POST',
        '/v1/files',
        headers => { 'Content-Type' => "multipart/form-data; boundary=$boundary" },
        content => $body,
    );
    return $future->then(sub {
        my ($res) = @_;
        my $file = Dedalus::Types::FileObject->from_hash($res->{data} || {});
        Future->done($file);
    });
}

sub delete {
    my ($self, $file_id, %opts) = @_;
    croak 'file_id is required' unless $file_id;
    my $future = $self->client->request_future('DELETE', "/v1/files/$file_id", %opts);
    return $future->then(sub {
        my ($res) = @_;
        Future->done($res->{data});
    });
}

1;
