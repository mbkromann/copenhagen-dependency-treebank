#!/usr/bin/perl -w

use strict;
use open IN  => ":crlf";

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

my $usage =
  "Convert atag file to aln file\n".
  "Arguments:\n".
  "  -A   <filename>     atag Alignment file -> aln file\n".
  "  -T   <filename>     tag file\n".
  "  -h   this help \n".
  "\n";

use vars qw ($opt_A $opt_T $opt_v $opt_h);

use Getopt::Std;
getopts ('A:T:hv:');

die $usage if defined($opt_h);

my  $Verbose = 0;

if (defined($opt_v)) {$Verbose = $opt_v;}
if (defined($opt_A)) {CheckAtag($opt_A);}
if (defined($opt_T)) {CheckTagFile($opt_T);}

exit;


sub CheckAtag {
  my ($fn) = @_;
  my ($D, $K, $fn1, $i, $io, $oo, $is, $os, $k); 

  if(!open(ALIGN,  "<:encoding(utf8)", $fn)) {
    printf STDERR "cannot open for reading: $fn\n";
    exit 1;
  }

  printf STDERR "ReadAtag Reading: $fn\n";

## read alignment file
  while(defined($_ = <ALIGN>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;

## read aligned files
    if(/<alignFile/) {
      if(/href="([^"]*)"/) { $fn1 = $1;}
################################ Change!!!
      $fn1 =~ s/.*\//\.\//;

## read reference file "a"
      if(/key="a"/) { 
        CheckTagFile($fn1);
        $D->{'a'}{'f'} =  $fn1;
        $D->{'a'}{'d'} =  ReadDTAG( $fn1); 
        if($fn1 =~ /src$/) { $SrcTgt = 2;}
      }
## read reference file "b"
      elsif(/key="b"/) { 
        CheckTagFile($fn1);
        $D->{'b'}{'f'} =  $fn1;
        $D->{'b'}{'d'} =  ReadDTAG( $fn1); 
        if($fn1 =~ /src$/) { $SrcTgt = 1;}
      }
      else {printf STDERR "Alignment wrong %s\n", $_;}
  
      next;
    }

    if(/<align /) {
#printf STDERR "ALN: $_\n";
      if(/in="([^"]*)"/) {$is=$1;}
      if(/out="([^"]*)"/){$os=$1;}

      ## aligned to itself
      if($is eq $os) {next;}

      if(/insign="([^"]*)"/) {$is=MSunescape($1);}
      if(/outsign="([^"]*)"/){$os=MSunescape($1);}

      if($is eq $os) {next;}

      if(/in="([^"]*)"/) { 
        $K = [split(/\s+/, $1)];
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { 
            if(defined($D->{$1}{'d'}{$2})) {
              if($is =~ $D->{$1}{'d'}{$2}{'<str>'}) {next;}
              else {printf STDERR "I: %s >$is\t$D->{$1}{'f'} >%s<\n", $K->[$i], $D->{$1}{'d'}{$2}{'<str>'};}
	    }
            else {printf STDERR "I: $K->[$i] >$is<\t undef $D->{$1}{'f'}\n";}
          }
	}
      }
      if(/out="([^"]*)"/) { 
        $K = [split(/\s+/, $1)];
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { 
            if(defined($D->{$1}{'d'}{$2})) {
              if($os =~ $D->{$1}{'d'}{$2}{'<str>'}) {next;}
              else {printf STDERR "O: %s >$os\t$D->{$1}{'f'} >%s<\n", $K->[$i], $D->{$1}{'d'}{$2}{'<str>'};}
	    }
            else {printf STDERR "O: $K->[$i] >$os<\t undef $D->{$1}{'f'}\n";}
          }
        }
#printf STDERR "OUT: %s\t$1\t$2\n", $K->[$i];
      }
    }
  }
  close (ALIGN);
}

sub ReadDTAG {
  my ($fn) = @_;
  my ($x, $k, $s, $D, $n); 

  if(!open(DATA, "<:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    exit ;
  }

  if($Verbose) {printf STDERR "ReadDtag Reading %s\n", $fn;}

  $n = -1;
  while(defined($_ = <DATA>)) {
    $n++;
#    if($_ =~ /^\s*$/) {next;}
#    if($_ =~ /^#/) {next;}
#    chomp;

    if(!/<W ([^>]*)>([^<]*)/) {next;} 
    $x = $1;
    $s = $2;
    if(/id="([^"])"/ && $1 != $n) {
      printf STDERR "Read $fn: unmatching n:$n and id:$1\n";
      $n=$1;
    }

    $s =~ s/([\(\)\\\/])/\\$1/g;
    $D->{$n}{'<str>'}=$s;
    $x =~ s/\s*([^=]*)\s*=\s*"([^"]*)\s*"/AttrVal($D, $n, $1, $2)/eg;
  }
  close (DATA);
  return $D;
}


sub AttrVal {
  my ($D, $n, $attr, $val) = @_;

#printf STDERR "$n:$attr:$val\t";
  $D->{$n}{$attr}=$val;
}


sub MSunescape {
  my ($in) = @_;

  $in =~ s/&amp;/\&/g;
  $in =~ s/&gt;/\>/g;
  $in =~ s/&lt;/\</g;
  $in =~ s/&#xA;/\n/g;
  $in =~ s/&#xD;/\r/g;
  $in =~ s/&#x9;/\t/g;
  $in =~ s/&quot;/"/g;
  return $in;
}

sub CheckTagFile {
  my ($fn) = @_;
  my ($H, $k, $s, $L, $n); 

  if(!open(DATA, "<:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    exit ;
  }

  $n = 1;
  while(defined($_ = <DATA>)) {

    $H->{$n}{'s'} = $_;
    if(/in="([^"]*)"/) {$H->{$n}{'i'} = $1;}
    if(/out="([^"]*)"/){$H->{$n}{'o'} = $1;}
    $n++;
  }
  close (DATA);

  my ($p, $o, $l);
  foreach $n  (sort {$a <=> $b} keys %{$H}) {
    if(defined($H->{$n}{'i'})) {
      $L = [split(/\|/, $H->{$n}{'i'})];
      for(my $i=0; $i <=$#{$L}; $i++) {
#printf STDERR "BBBB line $n link $i:\n";
#d($L->[$i]);
        ($o, $l) = split(/\:/, $L->[$i]);
	if(!defined($H->{$n + int($o)})) {printf STDERR "Err1:\n"; next;}
	if(!defined($H->{$n + int($o)}{'o'})) {printf STDERR "Err2:\n"; next;}
	$p = int($o) * -1;
#printf STDERR "AAAA %s %s %s %s\n", $n, $n+$o, $o, $p;
	$l =~ s/\[/\\\[/;
	if($H->{$n+$o}{'o'} =~ /$p:$l/){
#printf STDERR "OK line $n link $i $o:$l\n";
		next;}
printf STDERR "$fn line:$n link:$i no match in=$o:$l out=$H->{$n+$o}{'o'}\n\t%s $H->{$n+$o}{'s'}\n", $n+$o;
      }
    }
  }
}  
