#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw( :edit );

# delete incorrect utf8 characters

edit_file_lines (
    sub {
        s/compound=".(..).(1989..).(,)"/compound="$1$2$3"/gsxm;
    },
    'all_source_data/en/1252-en.tag'
) or die $!;


edit_file_lines (
    sub {
        s/(\").(sostener).(li\")/$1$2$3/gsxm;
        s/(\").(allenar).(li\")/$1$2$3/gsxm;
    },
    'all_source_data/it/1390-it-lisa.tag'
) or die $!;



