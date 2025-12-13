package Dedalus::Util::SSE;
use strict;
use warnings;

use Exporter 'import';
use Cpanel::JSON::XS qw(decode_json);

our @EXPORT_OK = qw(parse_sse to_stream_events);

sub parse_sse {
    my ($content) = @_;
    my @events;
    return \@events unless defined $content && length $content;

    my @blocks = split(/\n\n/, $content);
    for my $block (@blocks) {
        next unless length $block;
        my %event;
        for my $line (split(/\n/, $block)) {
            next unless length $line;
            my ($field, $value) = split(/:\s?/, $line, 2);
            $value //= '';
            if (exists $event{$field}) {
                $event{$field} .= "\n" . $value;
            } else {
                $event{$field} = $value;
            }
        }
        push @events, \%event if %event;
    }
    return \@events;
}

sub to_stream_events {
    my ($content) = @_;
    my $events = parse_sse($content);
    my @chunks;
    for my $event (@$events) {
        my $data = $event->{data};
        next unless defined $data;
        next if $data =~ /^\[DONE\]/;
        my $decoded;
        eval { $decoded = decode_json($data); 1 } or next;
        push @chunks, $decoded;
    }
    return \@chunks;
}

1;
