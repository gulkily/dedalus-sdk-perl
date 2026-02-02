package Dedalus::Types::Shared::ResponseFormatJSONSchema;
use Moo;
use Types::Standard qw(Str InstanceOf HashRef);

use Dedalus::Types::Shared::JSONSchema;

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'json_schema' },
);

has json_schema => (
    is       => 'ro',
    isa      => InstanceOf['Dedalus::Types::Shared::JSONSchema'],
    required => 1,
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $schema = $hash->{json_schema} || {};
    return $class->new(
        type        => $hash->{type} // 'json_schema',
        json_schema => Dedalus::Types::Shared::JSONSchema->from_hash($schema),
        raw         => $hash,
    );
}

1;
