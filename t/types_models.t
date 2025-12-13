use Test2::V0;
use Dedalus::Types::Model;
use Dedalus::Types::ListModelsResponse;
use JSON::PP;

my $raw_model = {
    id         => 'openai/gpt-5-nano',
    provider   => 'openai',
    created_at => '2024-01-01T00:00:00Z',
    description => 'Test model',
    capabilities => {
        text => JSON::PP::true,
        tools => JSON::PP::true,
        streaming => JSON::PP::false,
    },
    defaults => {
        temperature => 0.7,
    },
};

my $model = Dedalus::Types::Model->from_hash($raw_model);
isa_ok($model, 'Dedalus::Types::Model');
ok($model->capabilities->text, 'capabilities parsed');
ok($model->defaults->temperature == 0.7, 'defaults parsed');
is($model->capabilities->streaming, 0, 'json boolean coerced');

my $list = Dedalus::Types::ListModelsResponse->from_hash({ data => [ $raw_model ], object => 'list' });
isa_ok($list, 'Dedalus::Types::ListModelsResponse');
is($list->data->[0]->id, 'openai/gpt-5-nano', 'list wraps model objects');

done_testing;
