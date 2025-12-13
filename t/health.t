use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless { response => $_[1] }, $_[0] }
    sub request {
        my ($self, @args) = @_;
        return $self->{response};
    }
}

local $ENV{DEDALUS_API_KEY} = 'test-key';
my $response = {
    status  => 200,
    headers => { 'content-type' => 'application/json' },
    data    => { status => 'ok' },
    content => '{"status":"ok"}',
};

my $client = Dedalus::Client->new(
    http => TestHTTP->new($response),
);

my $health = $client->health->check;
isa_ok($health, 'Dedalus::Types::HealthCheckResponse');
is($health->status, 'ok', 'health status parsed');

done_testing;
