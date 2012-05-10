#!/usr/bin/perl -w

use strict;
use warnings;
use open IN  => ":crlf";

use File::Copy;
use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";


# Escape characters 
my $map = { map { $_ => 1 } split( //o, "\\<> \t\n\r\f\"" ) };


my $usage =
  "Precision and recall ProgGraph files: \n".
  "  -A in:  Alignment file <filename.atag\n".
  "  -R in:  Alignment file <filename.atag\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_R $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('A:R:v:t:h');

die $usage if defined($opt_h);

my $Verbose = 0;

if (defined($opt_v)) {$Verbose = $opt_v;}

### Read and Tokenize Translog log file
if(defined($opt_A) && defined($opt_R)) {
  my $A=ReadAtag($opt_A);
  my $R=ReadAtag($opt_R);
  if($A->{'a'} ne $R->{'a'}) { printf STDERR "ReadAtag: unequal references:$opt_A:$A->{'a'}\tand\t$opt_R:$R->{'a'}\n"; }
  if($A->{'b'} ne $R->{'b'}) { printf STDERR "ReadAtag: unequal references:$opt_A:$A->{'b'}\tand\t$opt_R:$R->{'b'}\n"; }
  ReacallPrecision($A, $R);
  exit;
}

die $usage;

exit;


sub ReadAtag {
  my ($fn) = @_;
  my ($A, $K, $fn1, $i, $is, $os, $lang, $n); 

  if(!open(ALIGN,  "<:encoding(utf8)", "$fn")) {
    printf STDERR "ReadAtag: cannot open for reading: $fn\n";
    exit 1;
  }

  if($Verbose) {printf STDERR "ReadAtag: $fn.atag\n";}

## read alignment file
  $n = 0;
  while(defined($_ = <ALIGN>)) {
    chomp;

    if(/<alignFile/) {
      if(/href="([^"]*)"/) { $fn1 = $1;}
      if(/key="a"/) { $A->{'a'} =  $fn1;}
      if(/key="b"/) { $A->{'b'} =  $fn1;}

    }
    if(/<align /) {
#        print STDERR "ReadAtag: skipping $fn already aligned\n";

#printf STDERR "ALN: $_\n";
      if(/in="([^"]*)"/) { $is=$1;}
      if(/out="([^"]*)"/){ $os=$1;}

      ## aligned to itself
      if($is eq $os) {next;}

      if(/insign="([^"]*)"/) { $is=$1;}
      if(/outsign="([^"]*)"/){ $os=$1;}

      if(/in="([^"]*)"/) {
        my $IN = [split(/\s+/, $1)];
        for(my $in=0; $in <=$#{$IN}; $in++) {
          if($IN->[$in] =~ /([ab])(\d+)/) {
            my $id_in = $2;
            if(/out="([^"]*)"/) {
              my $OUT = [split(/\s+/, $1)];
              for(my $out=0; $out <=$#{$OUT}; $out++) {
                if($OUT->[$out] =~ /([ab])(\d+)/) { $A->{'n'}{$id_in}{$2} ++; }
                else { printf STDERR "WARNING: $fn  out $_";}
              }
            }
          }
          else { printf STDERR "WARNING: $fn  in $_";}
        }
      }
      $n++;
    }
  }
  close (ALIGN);
  return ($A);
}


sub ReacallPrecision{
  my ($A, $R) = @_;

  my $hit = 0;
  my $miss = 0;
  my $noise = 0;
  foreach my $in (sort {$a<=>$b} keys %{$R->{n}}) {
    foreach my $out (sort {$a<=>$b} keys %{$R->{n}{$in}}) {
      if(defined($A->{n}{$in}) && defined($A->{n}{$in}{$out})) {
        $hit ++;
      }
      else {$miss ++}
  } }
  foreach my $in (sort {$a<=>$b} keys %{$A->{n}}) {
    foreach my $out (sort {$a<=>$b} keys %{$A->{n}{$in}}) {
      if(!defined($R->{n}{$in}) || defined($R->{n}{$in}{$out})) { $noise ++; }
  } }

  printf STDOUT "hit:$hit\tmiss:$miss\tnoise:$noise\tPrecision:%s\tRecall:%s\n", $hit/($hit+$noise),  $hit/($hit+$miss);
}
