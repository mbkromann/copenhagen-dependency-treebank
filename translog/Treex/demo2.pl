#!/usr/bin/env perl

use strict;
use warnings;

use Treex::Core;

my $doc = Treex::Core::Document->new;

my $doc_zone = $doc->create_zone('en');
$doc_zone->set_text('John goes to    ciname.This is the long text that contains
all English. This is a normal sentence. And this is another nice sentence.');

$doc->save('mysecond.treex.gz');
