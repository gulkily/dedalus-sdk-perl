package Dedalus::Util::SSE;
use strict;
use warnings;

use Exporter 'import';
use Cpanel::JSON::XS qw(decode_json);

our @EXPORT_OK = qw(parse_sse to_stream_events build_decoder);

sub parse_sse {
    my ($content) = @_;
    my @events;
    return \@events unless defined $content && length $content;

    $content =~ s/\r\n/\n/g;
    my @blocks = split(/\n\n/, $content);
    for my $block (@blocks) {
        my $event = _parse_block($block);
        push @events, $event if $event && %$event;
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

sub build_decoder {
    my ($callback) = @_;
    my $buffer = '';
    return sub {
        my ($chunk) = @_;
        return unless defined $chunk;
        $buffer .= $chunk;
        $buffer =~ s/\r\n/\n/g;
        while ((my $pos = index($buffer, "\n\n")) >= 0) {
            my $block = substr($buffer, 0, $pos);
            substr($buffer, 0, $pos + 2, '');
            my $event = _parse_block($block);
            next unless $event && $event->{data};
            if ($event->{data} =~ /^\[DONE\]/) {
                $callback->(undef);
                next;
            }
            my $decoded = eval { decode_json($event->{data}) };
            $callback->($decoded) if $decoded;
        }
    };
}

sub _parse_block {
    my ($block) = @_;
    return undef unless defined $block && length $block;
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
    return \%event;
}

1;
