package Dedalus::Types::Model::Defaults;
use Moo;
use Types::Standard qw(Maybe Int Num);

has max_output_tokens => (is => 'ro', isa => Maybe[Int]);
has temperature => (is => 'ro', isa => Maybe[Num]);
has top_k => (is => 'ro', isa => Maybe[Int]);
has top_p => (is => 'ro', isa => Maybe[Num]);

sub from_hash {
    my ($class, $hash) = @_;
    return undef unless $hash && ref $hash eq 'HASH';
    return $class->new(%{$hash});
}

1;
