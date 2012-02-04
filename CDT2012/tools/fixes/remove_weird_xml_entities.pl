#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );

my $regexp_mask = $ARGV[0] || '.';
my $datadir = '../../data/';

foreach my $filename (grep {/$regexp_mask/} glob "$datadir/tag-format/*/*") {
    edit_file {
        s/&3a;/:/g;
        s/&7c;/|/g;
        s/&22;/&quot;/g;
        s/&amp;quot;/&quot;/g;
        s/&nbsp;/ /g;
        s/(&\w+)([^\w;])/$1;$2/g; # missing ';' in entity, e.g. ...&amp...
    }
        $filename;
}
