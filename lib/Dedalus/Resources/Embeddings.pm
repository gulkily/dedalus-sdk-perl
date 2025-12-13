package Dedalus::Resources::Embeddings;
use Moo;
use Carp qw(croak);

use Dedalus::Types::CreateEmbeddingResponse;

has client => (
    is       => 'ro',
    required => 1,
);

my @ALLOWED_KEYS = qw(model input user encoding_format dimensions);

sub create {
    my ($self, %params) = @_;
    croak 'model is required' unless $params{model};
    croak 'input is required' unless exists $params{input};

    my %body;
    for my $key (@ALLOWED_KEYS) {
        next unless exists $params{$key};
        $body{$key} = $params{$key};
    }

    my $response = $self->client->request('POST', '/v1/embeddings', json => \%body);
    my $data = $response->{data} || {};
    return Dedalus::Types::CreateEmbeddingResponse->from_hash($data);
}

1;
