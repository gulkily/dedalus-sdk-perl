package Dedalus::Types::Model::Capabilities;
use Moo;
use Types::Standard qw(Maybe Bool Int);

has audio => (is => 'ro', isa => Maybe[Bool]);
has image_generation => (is => 'ro', isa => Maybe[Bool]);
has input_token_limit => (is => 'ro', isa => Maybe[Int]);
has output_token_limit => (is => 'ro', isa => Maybe[Int]);
has streaming => (is => 'ro', isa => Maybe[Bool]);
has structured_output => (is => 'ro', isa => Maybe[Bool]);
has text => (is => 'ro', isa => Maybe[Bool]);
has thinking => (is => 'ro', isa => Maybe[Bool]);
has tools => (is => 'ro', isa => Maybe[Bool]);
has vision => (is => 'ro', isa => Maybe[Bool]);

sub from_hash {
    my ($class, $hash) = @_;
    return undef unless $hash && ref $hash eq 'HASH';
    return $class->new(%{$hash});
}

1;
