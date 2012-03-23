#!/usr/bin/env perl

use strict;
use warnings;

use Treex::Core;

my $doc = Treex::Core::Document->new;

my $bundle = $doc->create_bundle;

my $zone = $bundle->create_zone('en');

my $root = $zone->create_atree;

open my $F,'<:utf8','input_sample.translog' or die $!;

my $ord;
while (<$F>) {
    chomp;
    $ord++;
    my ($letter,$curpos) = split / /;
    my $node = $root->create_child(ord=>$ord);

    $node->set_form($letter);

    $node->wild->{curpos} = $curpos;

    foreach my $i (0..10000) {
        $node->wild->{"a$i"} = "whatever$i";
    }
}


my $doc_zone = $doc->create_zone('en');
$doc_zone->set_text('John goes to    ciname.This is the long text that contains
all English. This is a normal sentence. And this is another nice sentence.');

$doc->save('myfirst.treex.gz');
