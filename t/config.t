use Test2::V0;

use Dedalus::Config;

sub with_env {
    my ($vars, $code) = @_;
    my %old;
    for my $key (keys %$vars) {
        $old{$key} = exists $ENV{$key} ? $ENV{$key} : undef;
        if (defined $vars->{$key}) {
            $ENV{$key} = $vars->{$key};
        } else {
            delete $ENV{$key};
        }
    }
    $code->();
    for my $key (keys %$vars) {
        if (defined $old{$key}) {
            $ENV{$key} = $old{$key};
        } else {
            delete $ENV{$key};
        }
    }
}

with_env({ DEDALUS_API_KEY => undef }, sub {
    like(dies { Dedalus::Config->new }, qr/DEDALUS_API_KEY is required/, 'api key required');
});

with_env({ DEDALUS_API_KEY => 'test-key', DEDALUS_ENVIRONMENT => undef, DEDALUS_BASE_URL => undef }, sub {
    my $config = Dedalus::Config->new;
    is($config->environment, 'production', 'default environment');
    is($config->base_url, 'https://api.dedaluslabs.ai', 'default base url');
});

with_env({ DEDALUS_API_KEY => 'test-key', DEDALUS_ENVIRONMENT => 'development', DEDALUS_BASE_URL => undef }, sub {
    my $config = Dedalus::Config->new;
    is($config->environment, 'development', 'environment from env');
    is($config->base_url, 'http://localhost:8080', 'base url from environment');
});

with_env({ DEDALUS_API_KEY => 'test-key', DEDALUS_BASE_URL => 'https://override.example' }, sub {
    my $config = Dedalus::Config->new;
    is($config->base_url, 'https://override.example', 'base url override');
});

with_env({ DEDALUS_API_KEY => 'test-key' }, sub {
    my $config = Dedalus::Config->new(default_headers => { 'X-Test' => 'yes' });
    my $headers = $config->headers;
    like($headers->{Authorization}, qr/^Bearer /, 'authorization header set');
    ok($headers->{'User-Agent'}, 'user agent set');
    is($headers->{'X-Test'}, 'yes', 'default headers merged');
});

with_env({ DEDALUS_API_KEY => 'test-key' }, sub {
    like(dies { Dedalus::Config->new(environment => 'staging') }, qr/Enum/, 'invalid environment rejected');
});

done_testing;
