package Dedalus::Resources::Audio::Transcriptions;
use Moo;
use Carp qw(croak);
use Dedalus::Types::Audio::TranscriptionCreateResponse;
use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    croak 'file is required' unless $params{file};
    croak 'model is required' unless $params{model};

    my $file_field = normalize_file_field($params{file}, 'upload.wav', 'application/octet-stream');
    my %fields = (
        file  => $file_field,
        model => $params{model},
    );
    $fields{language}        = $params{language}        if $params{language};
    $fields{prompt}          = $params{prompt}          if $params{prompt};
    $fields{response_format} = $params{response_format} if $params{response_format};
    $fields{temperature}     = $params{temperature}     if defined $params{temperature};

    my ($boundary, $body) = build_multipart_body(\%fields);

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

1;
