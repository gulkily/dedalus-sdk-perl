package Dedalus::Resources::Files;
use Moo;
use Carp qw(croak);

use Dedalus::Resources::Files::Content;
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
    return Dedalus::Resources::Files::Content->new(client => $self->client);
}

sub list {
    my ($self, %opts) = @_;
    my $response = $self->client->request('GET', '/v1/files', %opts);
    return Dedalus::Types::ListFilesResponse->from_hash($response->{data} || {});
}

sub retrieve {
    my ($self, $file_id, %opts) = @_;
    croak 'file_id is required' unless $file_id;
    my $response = $self->client->request('GET', "/v1/files/$file_id", %opts);
    return Dedalus::Types::FileObject->from_hash($response->{data} || {});
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
    my $response = $self->client->request(
        'POST',
        '/v1/files',
        headers => { 'Content-Type' => "multipart/form-data; boundary=$boundary" },
        content => $body,
    );
    return Dedalus::Types::FileObject->from_hash($response->{data} || {});
}

sub delete {
    my ($self, $file_id, %opts) = @_;
    croak 'file_id is required' unless $file_id;
    my $response = $self->client->request('DELETE', "/v1/files/$file_id", %opts);
    return $response->{data};
}

1;
