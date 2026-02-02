package Dedalus::Types::Response::OutputContentBlock;
use Moo;
use Types::Standard qw(Str Maybe HashRef InstanceOf);

use Dedalus::Types::Response::Audio;
use Dedalus::Types::Response::ImageURL;

has type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'text' },
);

has text => (
    is  => 'ro',
    isa => Maybe[Str],
);

has image_url => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Response::ImageURL']],
);

has audio => (
    is  => 'ro',
    isa => Maybe[InstanceOf['Dedalus::Types::Response::Audio']],
);

has raw => (
    is  => 'ro',
    isa => HashRef,
    required => 1,
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my $image_url;
    if (exists $hash->{image_url} && ref $hash->{image_url} eq 'HASH') {
        $image_url = Dedalus::Types::Response::ImageURL->from_hash($hash->{image_url});
    }
    my $audio;
    if (exists $hash->{audio} && ref $hash->{audio} eq 'HASH') {
        $audio = Dedalus::Types::Response::Audio->from_hash($hash->{audio});
    }
    return $class->new(
        type      => $hash->{type} // 'text',
        text      => $hash->{text},
        image_url => $image_url,
        audio     => $audio,
        raw       => $hash,
    );
}

1;
