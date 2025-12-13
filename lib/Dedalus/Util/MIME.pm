package Dedalus::Util::MIME;
use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(guess_content_type);

my %EXT_MAP = (
    txt  => 'text/plain',
    text => 'text/plain',
    json => 'application/json',
    csv  => 'text/csv',
    tsv  => 'text/tab-separated-values',
    md   => 'text/markdown',
    html => 'text/html',
    htm  => 'text/html',
    png  => 'image/png',
    jpg  => 'image/jpeg',
    jpeg => 'image/jpeg',
    gif  => 'image/gif',
    bmp  => 'image/bmp',
    webp => 'image/webp',
    svg  => 'image/svg+xml',
    wav  => 'audio/wav',
    mp3  => 'audio/mpeg',
    mp4  => 'video/mp4',
    webm => 'video/webm',
    pdf  => 'application/pdf',
    zip  => 'application/zip',
    tar  => 'application/x-tar',
    gz   => 'application/gzip',
    bz2  => 'application/x-bzip2',
    jsonl => 'application/jsonl',
);

sub guess_content_type {
    my ($filename) = @_;
    return unless defined $filename && length $filename;
    if ($filename =~ /\.([^.]+)$/) {
        my $ext = lc $1;
        return $EXT_MAP{$ext} if exists $EXT_MAP{$ext};
    }
    return;
}

1;
