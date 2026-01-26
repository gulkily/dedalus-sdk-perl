package Dedalus::Types::Audio::TranscriptionUsage;
use Moo;
use Types::Standard qw(Int Maybe Str InstanceOf HashRef);

use Dedalus::Types::Audio::TranscriptionUsageInputTokenDetails;

has type => (
    is  => 'ro',
    isa => Maybe[Str],
);

has input_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has output_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has total_tokens => (
    is  => 'ro',
    isa => Maybe[Int],
);

has input_token_details => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Audio::TranscriptionUsageInputTokenDetails']],
);

has raw => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $details;
    if (exists $hash->{input_token_details} && ref $hash->{input_token_details} eq 'HASH') {
        $details = Dedalus::Types::Audio::TranscriptionUsageInputTokenDetails->from_hash(
            $hash->{input_token_details}
        );
    }
    return $class->new(
        type                => $hash->{type},
        input_tokens        => $hash->{input_tokens},
        output_tokens       => $hash->{output_tokens},
        total_tokens        => $hash->{total_tokens},
        input_token_details => $details,
        raw                 => $hash,
    );
}

1;
