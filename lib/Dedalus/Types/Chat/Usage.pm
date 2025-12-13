package Dedalus::Types::Chat::Usage;
use Moo;
use Types::Standard qw(Int);

has prompt_tokens => (is => 'ro', isa => Int, default => sub { 0 });
has completion_tokens => (is => 'ro', isa => Int, default => sub { 0 });
has total_tokens => (is => 'ro', isa => Int, default => sub { 0 });

sub from_hash {
    my ($class, $hash) = @_;
    $hash ||= {};
    return $class->new(
        prompt_tokens     => $hash->{prompt_tokens} // 0,
        completion_tokens => $hash->{completion_tokens} // 0,
        total_tokens      => $hash->{total_tokens} // 0,
    );
}

1;
