package Dedalus::Resources::Embeddings;
use Moo;
use Carp qw(croak);

use Dedalus::Types::CreateEmbeddingResponse;
use Dedalus::Util::Params qw(require_params ensure_arrayref);

has client => (
    is       => 'ro',
    required => 1,
);

my @ALLOWED_KEYS = qw(model input user encoding_format dimensions);

sub create {
    my ($self, %params) = @_;
    require_params(\%params, qw(model input));

    my %body;
    for my $key (@ALLOWED_KEYS) {
        next unless exists $params{$key};
        $body{$key} = $params{$key};
    }
    $body{input} = ensure_arrayref($body{input}, 'input');

    my $response = $self->client->request('POST', '/v1/embeddings', json => \%body);
    my $data = $response->{data} || {};
    return Dedalus::Types::CreateEmbeddingResponse->from_hash($data);
}

1;
