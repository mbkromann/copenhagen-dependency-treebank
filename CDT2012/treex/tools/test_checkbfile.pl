#!/usr/bin/env perl

use strict;
use warnings;

use CheckAlignment;


my ($good,$bad) = CheckAlignment::check("../source_data/da-it/1428-da-it-morten.atag","../source_data/it/1428-it-morten.tag");

print "good/bad: $good/$bad\n";
#print join "",map{"$_"} @errors;
