package Dedalus::Async::Audio::Translations;
use Moo;
use Future;

use Dedalus::Types::Audio::TranslationCreateResponse;
use Dedalus::Util::Multipart qw(normalize_file_field build_multipart_body);

has client => (
    is       => 'ro',
    required => 1,
);

sub create {
    my ($self, %params) = @_;
    my $file_field = normalize_file_field($params{file}, 'audio.wav', 'application/octet-stream');
    my %fields = (
        file  => $file_field,
        model => $params{model},
    );
    $fields{prompt}          = $params{prompt}          if $params{prompt};
    $fields{response_format} = $params{response_format} if $params{response_format};
    $fields{temperature}     = $params{temperature}     if defined $params{temperature};

    my ($boundary, $body) = build_multipart_body(\%fields);

    my $future = $self->client->request_future(
        'POST',
        '/v1/audio/translations',
        headers => { 'Content-Type' => "multipart/form-data; boundary=$boundary" },
        content => $body,
    );

    return $future->then(sub {
        my ($res) = @_;
        my $resp = Dedalus::Types::Audio::TranslationCreateResponse->from_hash($res->{data} || {});
        Future->done($resp);
    });
}

1;
