use Test2::V0;
use Dedalus;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        if ($path =~ m{/v1/models/}) {
            return {
                status => 200,
                data   => {
                    id         => 'openai/gpt-5-nano',
                    provider   => 'openai',
                    created_at => '2024-01-01T00:00:00Z',
                },
            };
        }
        return {
            status => 200,
            data   => {
                object => 'list',
                data   => [
                    {
                        id         => 'openai/gpt-5-nano',
                        provider   => 'openai',
                        created_at => '2024-01-01T00:00:00Z',
                    },
                ],
            },
        };
    }
}

my $client = Dedalus::Client->new(api_key => 'test', http => TestHTTP->new);

my $single = $client->models->retrieve('openai/gpt-5-nano');
isa_ok($single, 'Dedalus::Types::Model');

my $list = $client->models->list;
isa_ok($list, 'Dedalus::Types::ListModelsResponse');
is($list->data->[0]->id, 'openai/gpt-5-nano', 'list data parsed');

done_testing;
