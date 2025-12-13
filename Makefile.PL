use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Dedalus',
    VERSION_FROM => 'lib/Dedalus/Version.pm',
    ABSTRACT     => 'Dedalus API client for Perl applications',
    AUTHOR       => 'Dedalus Labs',
    LICENSE      => 'mit',
    PREREQ_PM    => {
        'HTTP::Tiny'        => 0,
        'Cpanel::JSON::XS'  => 0,
        'Scalar::Util'      => 0,
        'Time::HiRes'       => 0,
    },
    TEST_REQUIRES => {
        'Test2::V0' => 0,
    },
    META_MERGE => {
        resources => {
            bugtracker => 'https://github.com/dedalus-labs/dedalus-sdk-perl/issues',
            repository => {
                type => 'git',
                url  => 'https://github.com/dedalus-labs/dedalus-sdk-perl.git',
                web  => 'https://github.com/dedalus-labs/dedalus-sdk-perl',
            },
        },
    },
);
