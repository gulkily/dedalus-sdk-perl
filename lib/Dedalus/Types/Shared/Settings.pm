package Dedalus::Types::Shared::Settings;
use Moo;
use Types::Standard qw(Any ArrayRef Bool HashRef Int Maybe Num Str InstanceOf);

use Dedalus::Types::Shared::SettingsReasoning;
use Dedalus::Types::Shared::SettingsToolChoiceMCPToolChoice;

has attributes => (is => 'ro', isa => Maybe[HashRef]);
has audio => (is => 'ro', isa => Maybe[HashRef]);
has deferred => (is => 'ro', isa => Maybe[Bool]);
has disable_automatic_function_calling => (is => 'ro', isa => Maybe[Bool]);
has extra_args => (is => 'ro', isa => Maybe[HashRef]);
has extra_headers => (is => 'ro', isa => Maybe[HashRef]);
has extra_query => (is => 'ro', isa => Maybe[HashRef]);
has frequency_penalty => (is => 'ro', isa => Maybe[Num]);
has generation_config => (is => 'ro', isa => Maybe[HashRef]);
has include_usage => (is => 'ro', isa => Maybe[Bool]);
has input_audio_format => (is => 'ro', isa => Maybe[Str]);
has input_audio_transcription => (is => 'ro', isa => Maybe[HashRef]);
has logit_bias => (is => 'ro', isa => Maybe[HashRef]);
has logprobs => (is => 'ro', isa => Maybe[Bool]);
has max_completion_tokens => (is => 'ro', isa => Maybe[Int]);
has max_tokens => (is => 'ro', isa => Maybe[Int]);
has metadata => (is => 'ro', isa => Maybe[HashRef]);
has modalities => (is => 'ro', isa => Maybe[ArrayRef[Str]]);
has n => (is => 'ro', isa => Maybe[Int]);
has output_audio_format => (is => 'ro', isa => Maybe[Str]);
has parallel_tool_calls => (is => 'ro', isa => Maybe[Bool]);
has prediction => (is => 'ro', isa => Maybe[HashRef]);
has presence_penalty => (is => 'ro', isa => Maybe[Num]);
has prompt_cache_key => (is => 'ro', isa => Maybe[Str]);
has reasoning => (is => 'ro', isa => Maybe[InstanceOf['Dedalus::Types::Shared::SettingsReasoning']]);
has reasoning_effort => (is => 'ro', isa => Maybe[Str]);
has response_format => (is => 'ro', isa => Maybe[HashRef]);
has response_include => (is => 'ro', isa => Maybe[ArrayRef[Str]]);
has safety_identifier => (is => 'ro', isa => Maybe[Str]);
has safety_settings => (is => 'ro', isa => Maybe[ArrayRef]);
has search_parameters => (is => 'ro', isa => Maybe[HashRef]);
has seed => (is => 'ro', isa => Maybe[Int]);
has service_tier => (is => 'ro', isa => Maybe[Str]);
has stop => (is => 'ro', isa => Maybe[Any]);
has store => (is => 'ro', isa => Maybe[Bool]);
has stream => (is => 'ro', isa => Maybe[Bool]);
has stream_options => (is => 'ro', isa => Maybe[HashRef]);
has structured_output => (is => 'ro', isa => Maybe[Any]);
has system_instruction => (is => 'ro', isa => Maybe[HashRef]);
has temperature => (is => 'ro', isa => Maybe[Num]);
has thinking => (is => 'ro', isa => Maybe[HashRef]);
has timeout => (is => 'ro', isa => Maybe[Num]);
has tool_choice => (is => 'ro', isa => Maybe[Any]);
has tool_config => (is => 'ro', isa => Maybe[HashRef]);
has top_k => (is => 'ro', isa => Maybe[Int]);
has top_logprobs => (is => 'ro', isa => Maybe[Int]);
has top_p => (is => 'ro', isa => Maybe[Num]);
has truncation => (is => 'ro', isa => Maybe[Str]);
has turn_detection => (is => 'ro', isa => Maybe[HashRef]);
has use_responses => (is => 'ro', isa => Maybe[Bool]);
has user => (is => 'ro', isa => Maybe[Str]);
has verbosity => (is => 'ro', isa => Maybe[Str]);
has voice => (is => 'ro', isa => Maybe[Str]);
has web_search_options => (is => 'ro', isa => Maybe[HashRef]);

sub from_hash {
    my ($class, $hash) = @_;
    return undef unless $hash && ref $hash eq 'HASH';
    my $reasoning = Dedalus::Types::Shared::SettingsReasoning->from_hash($hash->{reasoning});
    my $tool_choice = $hash->{tool_choice};
    if (ref $tool_choice eq 'HASH' && exists $tool_choice->{server_label} && exists $tool_choice->{name}) {
        $tool_choice = Dedalus::Types::Shared::SettingsToolChoiceMCPToolChoice->from_hash($tool_choice);
    }
    return $class->new(
        attributes                        => $hash->{attributes},
        audio                             => $hash->{audio},
        deferred                          => $hash->{deferred},
        disable_automatic_function_calling => $hash->{disable_automatic_function_calling},
        extra_args                        => $hash->{extra_args},
        extra_headers                     => $hash->{extra_headers},
        extra_query                       => $hash->{extra_query},
        frequency_penalty                 => $hash->{frequency_penalty},
        generation_config                 => $hash->{generation_config},
        include_usage                     => $hash->{include_usage},
        input_audio_format                => $hash->{input_audio_format},
        input_audio_transcription         => $hash->{input_audio_transcription},
        logit_bias                        => $hash->{logit_bias},
        logprobs                          => $hash->{logprobs},
        max_completion_tokens             => $hash->{max_completion_tokens},
        max_tokens                        => $hash->{max_tokens},
        metadata                          => $hash->{metadata},
        modalities                        => $hash->{modalities},
        n                                 => $hash->{n},
        output_audio_format               => $hash->{output_audio_format},
        parallel_tool_calls               => $hash->{parallel_tool_calls},
        prediction                        => $hash->{prediction},
        presence_penalty                  => $hash->{presence_penalty},
        prompt_cache_key                  => $hash->{prompt_cache_key},
        reasoning                         => $reasoning,
        reasoning_effort                  => $hash->{reasoning_effort},
        response_format                   => $hash->{response_format},
        response_include                  => $hash->{response_include},
        safety_identifier                 => $hash->{safety_identifier},
        safety_settings                   => $hash->{safety_settings},
        search_parameters                 => $hash->{search_parameters},
        seed                              => $hash->{seed},
        service_tier                      => $hash->{service_tier},
        stop                              => $hash->{stop},
        store                             => $hash->{store},
        stream                            => $hash->{stream},
        stream_options                    => $hash->{stream_options},
        structured_output                 => $hash->{structured_output},
        system_instruction                => $hash->{system_instruction},
        temperature                       => $hash->{temperature},
        thinking                          => $hash->{thinking},
        timeout                           => $hash->{timeout},
        tool_choice                       => $tool_choice,
        tool_config                       => $hash->{tool_config},
        top_k                             => $hash->{top_k},
        top_logprobs                      => $hash->{top_logprobs},
        top_p                             => $hash->{top_p},
        truncation                        => $hash->{truncation},
        turn_detection                    => $hash->{turn_detection},
        use_responses                     => $hash->{use_responses},
        user                              => $hash->{user},
        verbosity                         => $hash->{verbosity},
        voice                             => $hash->{voice},
        web_search_options                => $hash->{web_search_options},
    );
}

1;
