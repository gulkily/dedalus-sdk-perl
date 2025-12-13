package Dedalus::Types::ListFilesResponse;
use Moo;
use Types::Standard qw(Str ArrayRef InstanceOf);
use Dedalus::Types::FileObject;

has object => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'list' },
);

has data => (
    is      => 'ro',
    isa     => ArrayRef[InstanceOf['Dedalus::Types::FileObject']],
    default => sub { [] },
);

sub from_hash {
    my ($class, $hash) = @_;
    die 'expected hash ref' unless ref $hash eq 'HASH';
    my @files = map { Dedalus::Types::FileObject->from_hash($_) } @{ $hash->{data} || [] };
    return $class->new(
        object => $hash->{object} // 'list',
        data   => \@files,
    );
}

1;
