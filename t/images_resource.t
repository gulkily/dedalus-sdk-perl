use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last} = { method => $method, path => $path, opts => \%opts };
        return {
            status => 200,
            data   => {
                created => 123,
                data    => [ { url => 'https://example.com/img.png' } ],
            },
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $resp = $client->images->generate(prompt => 'A cat');
isa_ok($resp, 'Dedalus::Types::ImagesResponse');
is($resp->data->[0]->url, 'https://example.com/img.png', 'image parsed');
is($http->{last}{path}, '/v1/images/generations', 'generate endpoint used');

my $blob = "data";
$resp = $client->images->edit(prompt => 'A cat', image => \$blob);
isa_ok($resp, 'Dedalus::Types::ImagesResponse');
like($http->{last}{opts}{headers}{'Content-Type'}, qr{multipart/form-data}, 'edit multipart sent');

$resp = $client->images->create_variation(image => \$blob);
isa_ok($resp, 'Dedalus::Types::ImagesResponse');
like($http->{last}{path}, qr{variations}, 'variation endpoint used');

done_testing;
