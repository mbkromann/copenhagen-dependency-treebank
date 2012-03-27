#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw( :edit );

edit_file_lines (
    sub {
        s/compound=".(..).(1989..).(,)"/compound="$1$2$3"/gsxm;
    },
    'all_source_data/en/1252-en.tag'
) or die $!;

