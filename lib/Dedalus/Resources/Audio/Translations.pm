package Dedalus::Resources::Audio::Translations;
use Moo;
use Carp qw(croak);

use Dedalus::Types::Audio::TranslationCreateResponse;
use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    croak 'file is required' unless $params{file};
    croak 'model is required' unless $params{model};

    my %fields = (
        file  => normalize_file_field($params{file}, 'audio.wav', 'application/octet-stream'),
        model => $params{model},
    );
    $fields{prompt}          = $params{prompt}          if $params{prompt};
    $fields{response_format} = $params{response_format} if $params{response_format};
    $fields{temperature}     = $params{temperature}     if defined $params{temperature};

    my ($boundary, $body) = build_multipart_body(\%fields);
    my $response = $self->client->request(
        'POST',
        '/v1/audio/translations',
        headers => { 'Content-Type' => "multipart/form-data; boundary=$boundary" },
        content => $body,
    );

    return Dedalus::Types::Audio::TranslationCreateResponse->from_hash($response->{data} || {});
}

1;
