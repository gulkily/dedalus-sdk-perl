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
                object => 'list',
                model  => $opts{json}{model},
                usage  => { prompt_tokens => 3, total_tokens => 3 },
                data   => [
                    {
                        object    => 'embedding',
                        index     => 0,
                        embedding => [0.1, 0.2],
                    },
                ],
            },
        };
    }
}

my $http = TestHTTP->new;
my $client = Dedalus::Client->new(api_key => 'test', http => $http);

my $resp = $client->embeddings->create(
    model => 'text-embedding-3-small',
    input => 'hello world',
);

isa_ok($resp, 'Dedalus::Types::CreateEmbeddingResponse');
is($resp->data->[0]->index, 0, 'embeddings parsed');
is($http->{last}{path}, '/v1/embeddings', 'hits embeddings endpoint');
is($http->{last}{opts}{json}{input}, ['hello world'], 'input coerced to arrayref');

done_testing;
