package Dedalus::Types::Chat::Usage;
use Moo;
use Types::Standard qw(Int Maybe InstanceOf);

use Dedalus::Types::Chat::UsageCompletionTokensDetails;
use Dedalus::Types::Chat::UsagePromptTokensDetails;

has prompt_tokens => (is => 'ro', isa => Int, default => sub { 0 });
has completion_tokens => (is => 'ro', isa => Int, default => sub { 0 });
has total_tokens => (is => 'ro', isa => Int, default => sub { 0 });

has completion_tokens_details => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Chat::UsageCompletionTokensDetails']],
);

has prompt_tokens_details => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Chat::UsagePromptTokensDetails']],
);

sub from_hash {
    my ($class, $hash) = @_;
    $hash ||= {};
    my $completion_details;
    if (exists $hash->{completion_tokens_details} && ref $hash->{completion_tokens_details} eq 'HASH') {
        $completion_details = Dedalus::Types::Chat::UsageCompletionTokensDetails->from_hash(
            $hash->{completion_tokens_details}
        );
    }
    my $prompt_details;
    if (exists $hash->{prompt_tokens_details} && ref $hash->{prompt_tokens_details} eq 'HASH') {
        $prompt_details = Dedalus::Types::Chat::UsagePromptTokensDetails->from_hash(
            $hash->{prompt_tokens_details}
        );
    }
    return $class->new(
        prompt_tokens            => $hash->{prompt_tokens} // 0,
        completion_tokens        => $hash->{completion_tokens} // 0,
        total_tokens             => $hash->{total_tokens} // 0,
        completion_tokens_details => $completion_details,
        prompt_tokens_details     => $prompt_details,
    );
}

1;
