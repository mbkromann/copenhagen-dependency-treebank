#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw( :edit );

edit_file_lines (
    sub {
        s/<W id="242" in="" out="">assoc-const<\/W>//;
        s/<W id="243" in="" out="">assoc-formal<\/W>//;
    },
    'all_source_data/da/0870-da.tag'
) or die $!;



