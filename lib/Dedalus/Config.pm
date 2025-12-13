package Dedalus::Config;
use Moo;
use Types::Standard qw(Str HashRef Maybe Enum Num);
use Dedalus::Version ();

my %ENVIRONMENTS = (
    production  => 'https://api.dedaluslabs.ai',
    development => 'http://localhost:8080',
);

has api_key => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has environment => (
    is      => 'ro',
    isa     => Enum[qw(production development)],
    default => sub { 'production' },
);

has base_url => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => '_build_base_url',
);

has timeout => (
    is      => 'ro',
    isa     => Num,
    default => sub { 60 },
);

has default_headers => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;

    $args{api_key} //= $ENV{DEDALUS_API_KEY};
    die 'DEDALUS_API_KEY is required' unless $args{api_key};

    $args{environment} //= ($ENV{DEDALUS_ENVIRONMENT} // 'production');
    if (my $base = $ENV{DEDALUS_BASE_URL}) {
        $args{base_url} //= $base;
    }

    return $class->$orig(%args);
};

sub _build_base_url {
    my ($self) = @_;
    return $ENVIRONMENTS{$self->environment} if exists $ENVIRONMENTS{$self->environment};
    die 'Unknown environment: ' . $self->environment;
}

sub headers {
    my ($self) = @_;
    my %headers = (
        'Authorization' => 'Bearer ' . $self->api_key,
        'User-Agent'    => 'Dedalus-PerlSDK/' . Dedalus::Version::version(),
        'X-SDK-Version' => Dedalus::Version::version(),
        %{ $self->default_headers },
    );
    return \%headers;
}

sub environments { return { %ENVIRONMENTS } }

1;
