package Dedalus::Resources::Files::Content;
use Moo;
use Carp qw(croak);

has client => (
    is       => 'ro',
    required => 1,
);

sub retrieve {
    my ($self, $file_id, %opts) = @_;
    croak 'file_id is required' unless $file_id;
    my $response = $self->client->request('GET', "/v1/files/$file_id/content", %opts);
    return {
        status  => $response->{status},
        headers => $response->{headers},
        content => $response->{content},
    };
}

1;
