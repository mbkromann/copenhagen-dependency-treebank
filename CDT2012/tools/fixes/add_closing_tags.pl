#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;

my $datadir = '../../data/';

foreach my $filename (glob "$datadir/tag-format/*/*.tag") {

    my $content = File::Slurp::read_file( $filename );

    my @segments = split /</,$content;

    my @stack;
    my @new_segments;

    my $file_changed;

    foreach my $segment (grep {/./} @segments) {

        $segment =~ /^(\/?)([^\s\/\>]+)((\s+\S+=\"[^"]*\")*)\s*(\/?)/
            or die "Error: segment not matching the expected pattern: $segment\n";

        my ($slash_before, $tag, $attribs, $slash_after) = ($1,$2,$3,$5);
#        print "$segment\n  slashbefore:$slash_before  slash_after:$slash_after  tag: $tag\n\n";

        if (not $slash_before and not $slash_after) {
            if ($tag eq 'div1' and defined $stack[-1] and $stack[-1] eq 'div1') {
                print "div1 not closed, stack top: $stack[-1] \n";
                push @new_segments, "/div1>\n";
                $file_changed = 1;
                pop @stack;
            }
            push @stack, $tag;
        }

        elsif ($slash_before) {
            if ($stack[-1] eq $tag) {
                pop @stack;
            }
            else {
                print "filename: $filename\n";
                print "expected closing tag: $stack[-1]    got: $tag\n";
            }
        }

        push @new_segments, $segment;

    }

    if ($file_changed) {
        print "Storing changes in file $filename \n";
        open my $OUT, ">",$filename;
        print $OUT  join '', map {"<$_"} @new_segments;
        close $OUT;
    }

}
