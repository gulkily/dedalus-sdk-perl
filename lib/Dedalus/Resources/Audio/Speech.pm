package Dedalus::Resources::Audio::Speech;
use Moo;
use Carp qw(croak);

has client => (
    is       => 'ro',
    required => 1,
);

my @REQUIRED = qw(input model voice);
my @OPTIONAL = qw(instructions response_format speed stream_format);

sub create {
    my ($self, %params) = @_;
    for my $field (@REQUIRED) {
        croak "$field is required" unless defined $params{$field} && $params{$field} ne '';
    }

    my %body;
    $body{$_} = $params{$_} for @REQUIRED;
    for my $field (@OPTIONAL) {
        $body{$field} = $params{$field} if exists $params{$field};
    }

    my $response = $self->client->request(
        'POST',
        '/v1/audio/speech',
        headers => { Accept => 'audio/mpeg' },
        json    => \%body,
    );

    return {
        content => $response->{content},
        headers => $response->{headers},
        status  => $response->{status},
    };
}

1;
