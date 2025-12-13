package Dedalus::FileUpload;
use Moo;
use Types::Standard qw(Str Maybe HashRef);
use File::Basename qw(basename);
use Scalar::Util qw(openhandle);
use Carp qw(croak);

use Dedalus::Util::MIME qw(guess_content_type);

has filename => (
    is  => 'ro',
    isa => Maybe[Str],
);

has content_type => (
    is  => 'ro',
    isa => Maybe[Str],
);

has metadata => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has _source_type => (
    is       => 'ro',
    required => 1,
);

has _source => (
    is       => 'ro',
    required => 1,
);

has _cached_content => (
    is      => 'rw',
    clearer => '_clear_cached_content',
);

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    for my $key (qw(content path handle)) {
        next unless exists $args{$key};
        my $value = delete $args{$key};
        croak 'handle must be an open filehandle'
          if $key eq 'handle' && !openhandle($value);
        $args{_source_type} = $key;
        $args{_source}      = $value;
        return $class->$orig(%args);
    }
    croak 'Dedalus::FileUpload requires content => $scalar, path => $path, or handle => $fh';
};

sub from_path {
    my ($class, $path, %opts) = @_;
    croak "Path $path does not exist" unless defined $path && -e $path;
    return $class->new(path => $path, %opts);
}

sub from_handle {
    my ($class, $handle, %opts) = @_;
    croak 'handle is required' unless $handle;
    croak 'handle must be open' unless openhandle($handle);
    return $class->new(handle => $handle, %opts);
}

sub from_content {
    my ($class, $content, %opts) = @_;
    croak 'content must be defined' unless defined $content;
    return $class->new(content => $content, %opts);
}

sub content {
    my ($self) = @_;
    my $cached = $self->_cached_content;
    return $cached if defined $cached;

    my $data;
    if ($self->_source_type eq 'content') {
        $data = $self->_source;
    } elsif ($self->_source_type eq 'path') {
        open my $fh, '<', $self->_source or croak "Unable to read " . $self->_source . ": $!";
        binmode $fh;
        local $/;
        $data = <$fh>;
        close $fh;
    } elsif ($self->_source_type eq 'handle') {
        my $fh = $self->_source;
        binmode $fh;
        my $pos = eval { tell($fh) };
        seek($fh, 0, 0) if defined $pos && $pos >= 0;
        local $/;
        $data = <$fh>;
        seek($fh, $pos, 0) if defined $pos && $pos >= 0;
    } else {
        croak 'Unsupported file source';
    }

    $data //= '';
    $self->_cached_content($data);
    return $data;
}

sub to_field {
    my ($self, %opts) = @_;
    my $filename = $self->_resolve_filename($opts{default_filename});
    my $ctype    = $self->content_type
      || $opts{default_content_type}
      || guess_content_type($filename)
      || 'application/octet-stream';

    return {
        filename     => $filename,
        content      => $self->content,
        content_type => $ctype,
    };
}

sub _resolve_filename {
    my ($self, $default) = @_;
    return $self->filename if $self->filename;
    if ($self->_source_type eq 'path') {
        return basename($self->_source);
    }
    return $default if $default;
    return 'upload.dat';
}

1;
