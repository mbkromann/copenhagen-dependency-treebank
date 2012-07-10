#!/usr/bin/perl -w

use strict;
use open IN  => ":crlf";

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

my $usage =
  "Insert Language in src and tgt file\n".
  "Arguments:\n".
  "  -A   file root {src.tgt.atag}\n".
  "  -s   source language \n".
  "  -t   target language \n".
  "  -f   tag 1:src,2:tgt,3:atag \n".
  "  -h   this help \n".
  "\n";

use vars qw ($opt_s $opt_t $opt_f $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('s:t:f:A:hv:');

die $usage if defined($opt_h);

my $Resource = 1;
die $usage if (!defined($opt_f) || !defined($opt_A) || !defined($opt_s) || !defined($opt_t));

if($opt_f == 1) {LangInsertToken("$opt_A.src", $opt_s);}
if($opt_f == 2) {LangInsertToken("$opt_A.tgt", $opt_t); }
if($opt_f == 3) {LangInsertAtag("$opt_A.atag", $opt_s, $opt_t);}

exit;


sub LangInsertToken {
  my ($fn, $lang) = @_;

  printf STDERR "Reading: $fn\n";
  
  if(!open(F,  "<:encoding(utf8)", "$fn")) {
    printf STDERR "cannot open for reading: $fn\n";
    exit 1;
  }   
      
  while(defined($_ = <F>)) {
    
    if(/<Text/) {
      chomp;
      if(/language=/ &&  !/language=\"$lang\"/) { print STDERR "Warning  switching $_\tto\tlanguage=\"$lang\" \n"; }
      print STDOUT "<Text language=\"$lang\" \>\n";
    }
    else{ print STDOUT $_;}
  }
  close (F);
}


sub LangInsertAtag {
  my ($fn, $s, $t) = @_;

  printf STDERR "Reading: $fn\n";

  if(!open(F,  "<:encoding(utf8)", "$fn")) {
    printf STDERR "cannot open for reading: $fn\n";
    exit 1;
  }

  while(defined($_ = <F>)) {
    
    if(/<DTAGalign/) {
      chomp;
      if(/source=/ &&  !/source=\"$s\"/) { print STDERR "Warning  switching $_\tto\tsource=\"$s\" \n"; }
      if(/target=/ &&  !/target=\"$t\"/) { print STDERR "Warning  switching $_\tto\ttarget=\"$t\" \n"; }
      print STDOUT "<DTAGalign source=\"$s\" target=\"$t\" \>\n";
    }
    else{ print STDOUT $_;}
  }
  close (F);
}


