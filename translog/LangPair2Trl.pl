#!/usr/bin/perl -w

use strict;
use open IN  => ":crlf";

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

my $usage =
  "Insert Language pair in Translog file\n".
  "Arguments:\n".
  "  -T   <TranslogFile>     tag file\n".
  "  -s   source language \n".
  "  -t   target language \n".
  "  -h   this help \n".
  "\n";

use vars qw ($opt_s $opt_t $opt_T $opt_v $opt_h);

use Getopt::Std;
getopts ('s:t:T:hv:');

die $usage if defined($opt_h);
die $usage if (!defined($opt_T) || !defined($opt_s) || !defined($opt_t));

InsertLangPair($opt_T, $opt_s, $opt_t);

exit;


sub InsertLangPair {
  my ($fn, $s, $t) = @_;

  if(!open(F,  "<:encoding(utf8)", $fn)) {
    printf STDERR "cannot open for reading: $fn\n";
    exit 1;
  }

  printf STDERR "Reading: $fn\n";

## read alignment file
  while(defined($_ = <F>)) {

    if(/<Languages/) {next;} 
    if(/<Plugins/) { printf STDOUT "    <Languages source=\"$s\" target=\"$t\" />\n";}
    printf STDOUT $_;
  }
  close(F);
}
