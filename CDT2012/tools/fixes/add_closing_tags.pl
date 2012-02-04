#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;

my $datadir = '../../data/';
my $regexp_mask = $ARGV[0] || '.';

my %embeding = (
    W => 1,
    s => 2,
    p => 3,
    root => 4,
);


foreach my $filename (grep {/$regexp_mask/} glob "$datadir/tag-format/*/*.tag") {

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

        my $stacktop = $stack[-1];

        if (not $slash_before and not $slash_after) { # new opening tag

            if (defined $embeding{$tag} and defined $stacktop and defined $embeding{$stacktop}) { # fixing unexpected opening tag

                while ( $embeding{$tag} >= $embeding{$stacktop} ) { # the same or higher-level element is opened
                    pop @stack;
#                    print "Inserting tag $stacktop\n";
                    pushlog(\@new_segments, "/$stacktop>\n"); # as if I have seen the closing tag
                    $stacktop = $stack[-1];
                    $file_changed = 1;
                }
            }

            push @stack, $tag;
        }

        elsif ($slash_before) {
            if ($stack[-1] eq $tag) {
                pop @stack;
            }

            # fixing unexpected closing tag
            elsif ( $embeding{$tag} > $embeding{$stacktop} ) { # e.g. seen </root>, but missing closing </s> and </p>
                while ($embeding{$tag} > $embeding{$stacktop}) {
                    pushlog(\@new_segments, "/$stacktop>\n"); # as if I have seen the closing tag
                    pop @stack;
                    $stacktop = $stack[-1];
                    $file_changed = 1;
                }
            }

            else {
                print "filename: $filename\n";
                print "expected closing tag: $stack[-1]    got: $tag\n";
            }
        }

        pushlog(\@new_segments, $segment);

    }

    if ($file_changed) {
        print "Storing changes in file $filename \n";
        open my $OUT, ">",$filename;
        print $OUT  join '', map {"<$_"} @new_segments;
        close $OUT;
    }

}

my $line;
sub pushlog {
    my ($array_ref, $value) = @_;
    push @$array_ref, $value;
    $line++;
#    print "l$line: <$value";
}
