use Test2::V0;
use Dedalus::Client;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        $self->{last} = { method => $method, path => $path, opts => \%opts };
        return {
            status => 200,
            data   => {
                id       => 'file-1',
                object   => 'file',
                filename => 'upload.dat',
            },
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $payload = "hello";
my $resp = $client->files->upload(
    purpose  => 'fine-tune',
    file     => \$payload,
    metadata => { foo => 'bar' },
);

isa_ok($resp, 'Dedalus::Types::FileObject');

is($http->{last}{method}, 'POST', 'uses POST');
is($http->{last}{path}, '/v1/files', 'uploads to files endpoint');

my $headers = $http->{last}{opts}{headers};
like($headers->{'Content-Type'}, qr/multipart\/form-data; boundary=/, 'multipart header set');

my $body = $http->{last}{opts}{content} // '';
like($body, qr/Content-Disposition: form-data; name="purpose"/, 'purpose field included');
like($body, qr/Content-Disposition: form-data; name="metadata"/, 'metadata field included');
like($body, qr/"foo"\s*:\s*"bar"/, 'metadata encoded as json');
like($body, qr/filename="upload\.dat"/, 'default filename used');
like($body, qr/hello/, 'file content included');

done_testing;
