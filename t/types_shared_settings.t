use Test2::V0;
use Dedalus::Types::Shared::Settings;
use Dedalus::Types::Shared::SettingsReasoning;
use Dedalus::Types::Shared::SettingsToolChoiceMCPToolChoice;
use Dedalus::Types::Shared::DedalusModel;
use Dedalus::Types::Shared::DedalusModelChoice;

my $settings = Dedalus::Types::Shared::Settings->from_hash({
    temperature  => 0.2,
    modalities   => ['text', 'audio'],
    stream       => 1,
    stop         => ["\n\n"],
    reasoning    => { effort => 'low', summary => 'concise' },
    tool_choice  => { name => 'search', server_label => 'mcp' },
});

isa_ok($settings, 'Dedalus::Types::Shared::Settings');
isa_ok($settings->reasoning, 'Dedalus::Types::Shared::SettingsReasoning');
is($settings->reasoning->effort, 'low', 'reasoning parsed');
isa_ok($settings->tool_choice, 'Dedalus::Types::Shared::SettingsToolChoiceMCPToolChoice');
is($settings->tool_choice->name, 'search', 'tool choice parsed');

my $model = Dedalus::Types::Shared::DedalusModel->from_hash({
    model    => 'openai/gpt-5-nano',
    settings => { temperature => 0.1 },
});
isa_ok($model, 'Dedalus::Types::Shared::DedalusModel');
isa_ok($model->settings, 'Dedalus::Types::Shared::Settings');

is(Dedalus::Types::Shared::DedalusModelChoice->from_value('openai/gpt-5-nano'), 'openai/gpt-5-nano', 'choice accepts string');
isa_ok(
    Dedalus::Types::Shared::DedalusModelChoice->from_value({ model => 'openai/gpt-5-nano' }),
    'Dedalus::Types::Shared::DedalusModel',
);

done_testing;
