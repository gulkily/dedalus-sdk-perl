use Test2::V0;
use Dedalus::Types::Chat::ModelID;
use Dedalus::Types::Chat::ModelsParam;
use Dedalus::Types::Shared::DedalusModel;

is(Dedalus::Types::Chat::ModelID->from_value('openai/gpt-5-nano'), 'openai/gpt-5-nano', 'model id passthrough');

my $models = Dedalus::Types::Chat::ModelsParam->from_value([
    'openai/gpt-5-nano',
    {
        model    => 'anthropic/claude-3-5-sonnet',
        settings => { temperature => 0.2 },
    },
]);

is($models->[0], 'openai/gpt-5-nano', 'string model retained');
isa_ok($models->[1], 'Dedalus::Types::Shared::DedalusModel');
is($models->[1]->model, 'anthropic/claude-3-5-sonnet', 'model hash coerced');

like(dies { Dedalus::Types::Chat::ModelsParam->from_value('bad') }, qr/array/, 'models param validation');

done_testing;
