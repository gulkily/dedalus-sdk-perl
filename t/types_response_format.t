use Test2::V0;
use Dedalus::Types::Shared::ResponseFormatText;
use Dedalus::Types::Shared::ResponseFormatJSONObject;
use Dedalus::Types::Shared::ResponseFormatJSONSchema;
use Dedalus::Types::Shared::JSONSchema;

my $text = Dedalus::Types::Shared::ResponseFormatText->from_hash({ type => 'text' });
is($text->type, 'text', 'text response format parsed');

my $json_object = Dedalus::Types::Shared::ResponseFormatJSONObject->from_hash({ type => 'json_object' });
is($json_object->type, 'json_object', 'json_object response format parsed');

my $schema = Dedalus::Types::Shared::JSONSchema->from_hash({
    name        => 'Answer',
    description => 'Structured answer',
    schema      => { type => 'object', properties => { answer => { type => 'string' } } },
    strict      => 1,
});
is($schema->name, 'Answer', 'json schema name parsed');
is($schema->schema->{type}, 'object', 'json schema body parsed');

my $json_schema = Dedalus::Types::Shared::ResponseFormatJSONSchema->from_hash({
    type        => 'json_schema',
    json_schema => {
        name   => 'Answer',
        schema => { type => 'object' },
    },
});
is($json_schema->type, 'json_schema', 'json_schema response format parsed');
isa_ok($json_schema->json_schema, 'Dedalus::Types::Shared::JSONSchema');

like(dies { Dedalus::Types::Shared::ResponseFormatText->from_hash('bad') }, qr/hash/, 'format validation');

done_testing;
