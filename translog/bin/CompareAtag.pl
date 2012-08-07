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
  "Compare Atag files: \n".
  "  -A in:  Atag file1 <filename1>.{atag,src,tgt}\n".
  "  -C in:  Atag file2 <filename2>.{atag,src,tgt}\n".
  "Options:\n".
  "  -t starting token id [1] \n".
  "  -f fixation unit gap \n".
  "  -p production unit gap \n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_f $opt_p $opt_t $opt_C $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('C:A:f:p:v:t:h');

die $usage if defined($opt_h);

my $TRANSLOG = {};
my $Verbose = 0;

if (defined($opt_v)) {$Verbose = $opt_v;}

### Read and Tokenize Translog log file
if (defined($opt_C) && defined($opt_A)) {
  my $ATAG1=ReadAtag($opt_A);
  my $ATAG2=ReadAtag($opt_C);
  CompareAtag($ATAG1, $ATAG2);
  exit;
}

printf STDERR "No Output produced\n";
die $usage;

exit;

############################################################
# escape
############################################################

sub escape {
  my ($in) = @_;
#printf STDERR "in: $in\n";
  $in =~ s/(.)/exists($map->{$1})?sprintf('\\%04x',ord($1)):$1/egos;
  return $in;
}

sub unescape {
  my ($in) = @_;
  $in =~ s/\\([0-9a-f]{4})/sprintf('%c',hex($1))/egos;
  return $in;
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
  $in =~ s/&nbsp;/ /g;
  return $in;
}

sub MSescape {
  my ($in) = @_;

  $in =~ s/\&/&amp;/g;
  $in =~ s/\>/&gt;/g;
  $in =~ s/\</&lt;/g;
  $in =~ s/\n/&#xA;/g;
  $in =~ s/\r/&#xD;/g;
  $in =~ s/\t/&#x9;/g;
  $in =~ s/"/&quot;/g;
  $in =~ s/ /&nbsp;/g;
  return $in;
}



############################################################
# Read src and tgt files
############################################################


sub ReadDTAG {
  my ($fn) = @_;
  my ($x, $k, $s, $D, $n); 

  if(!open(DATA, "<:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    exit ;
  }

  if($Verbose) {printf STDERR "ReadDtag: %s\n", $fn;}

  $n = 1;
  while(defined($_ = <DATA>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;
#printf STDERR "$_\n";

    if(!/<W ([^>]*)>([^<]*)/) {next;} 
    $x = $1;
    $s = unescape($2);
    if(/id="([^"])"/ && $1 != $n) {
      printf STDERR "Read $fn: unmatching n:$n and id:$1\n";
      $n=$1;
    }

    $s =~ s/([\(\)\\\/])/\\$1/g;
    $D->{$n}{'tok'}=$s;
#printf STDERR "\tvalue:$2\t";
    $x =~ s/\s*([^=]*)\s*=\s*"([^"]*)\s*"/AttrVal($D, $n, $1, $2)/eg;
    if(defined($D->{$n}{id}) && $D->{$n}{id} != $n)  {
      print STDERR "ReadDTAG: IDs $fn: n:$n\tid:$D->{$n}{id}\n";
    }
    $n++;
  }
  close (DATA);
  return $D;
}

############################################################
# Read Atag file
############################################################

sub AttrVal {
  my ($D, $n, $attr, $val) = @_;

#printf STDERR "$n:$attr:$val\t";
  $D->{$n}{$attr}=unescape($val);
}


sub ReadAtag {
  my ($fn) = @_;
  my ($A, $K, $fn1, $i, $is, $os, $lang, $n); 

  if(!open(ALIGN,  "<:encoding(utf8)", "$fn.atag")) {
    printf STDERR "cannot open for reading: $fn.atag\n";
    exit 1;
  }

  if($Verbose) {printf STDERR "ReadAtag: $fn.atag\n";}

## read alignment file
  $A->{'fn'} =  "$fn.atag";
  while(defined($_ = <ALIGN>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;

#printf STDERR "Alignment %s\n", $_;
## read aligned files
    if(/<alignFile/) {
      my $path = $fn;
      if(/href="([^"]*)"/) { $fn1 = $1;}

## read reference file "a"
      if(/key="a"/) { 
        if($fn1 =~ /src$/)    { $lang='Source'; $A->{'a'}{'lang'} = 'Source'; $path .= ".src";}
        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'a'}{'lang'} = 'Final'; $path .= ".tgt";}
        $A->{'b'}{'fn'} =  $path;
        $A->{$lang}{'fn'} =  $path;
      }
## read reference file "b"
      elsif(/key="b"/) { 
        $A->{'b'}{'fn'} =  $path;
        if($fn1 =~ /src$/) { $lang='Source'; $A->{'b'}{'lang'} = 'Source'; $path .= ".src";}
        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'b'}{'lang'} = 'Final';$path .= ".tgt";}
        $A->{$lang}{'fn'} =  $path;
      }
      else {printf STDERR "Alignment wrong %s\n", $_;}

      $A->{$lang}{'D'} =  ReadDTAG("$path"); 
  
      next;
    }

    if(/<align /) {
#printf STDERR "ALN: $_\n";
      if(/in="([^"]*)"/) { $is=$1;}
      if(/out="([^"]*)"/){ $os=$1;}

      ## aligned to itself
      if($is eq $os) {next;}

      if(/last="([^"]*)"/) { $A->{'e'}{$n} = $1}

#print STDERR "ReadAtag5\n";
      my $Key1;
      my $Key2;
      if(/out="([^"]*)"/) { $Key1 = [split(/\s+/, $1)];}
      if(/in="([^"]*)"/)  { $Key2 = [split(/\s+/, $1)];}

      for($i=0; $i <=$#{$Key1}; $i++) {
        if($Key1->[$i] =~ /([ab])(\d+)/) { 
          my $key1 = $1;
          my $val1 = $2;
          for(my $j=0; $j <=$#{$Key2}; $j++) {
            if($Key2->[$j] =~ /([ab])(\d+)/) { 
              my $key2 = $1;
              my $val2 = $2;
              $A->{'n'}{$A->{$key1}{'lang'}}{$val1}{$A->{$key2}{'lang'}}{$val2} ++;
#print STDERR "ReadAtag6 $A->{'fn'}\t$key1:$val1 $key2:$val2 \n";
            }
          }
#printf STDERR "IN:  %s\t$1\t$2\n", $K->[$i];
        }
      }
    }
  }
  close (ALIGN);
  return ($A);
}


##########################################################
# Read Translog Logfile
##########################################################

## SourceText Positions
sub CompareAtag {
  my ($A1, $A2) = @_;

  foreach my $lang1 (keys %{$A1->{'n'}}) {
    foreach my $id1 (sort {$a<=>$b} keys %{$A1->{'n'}{$lang1}}) {
      foreach my $lang2 (keys %{$A1->{'n'}{$lang1}{$id1}}) {
        foreach my $id2 (sort {$a<=>$b} keys %{$A1->{'n'}{$lang1}{$id1}{$lang2}}) {
#print STDERR "CompareAtag5\n";
          if(!defined($A2->{'n'}{$lang1}{$id1}{$lang2}{$id2})) {
              print STDERR "$A2->{fn}\tmissing alignment:\t$lang1 $id1  <-> $lang2 $id2\n";
          }
        }
      }
    }
  }

  foreach my $lang1 (keys %{$A2->{'n'}}) {
    foreach my $id1 (sort {$a<=>$b} keys %{$A2->{'n'}{$lang1}}) {
      foreach my $lang2 (keys %{$A2->{'n'}{$lang1}{$id1}}) {
        foreach my $id2 (sort {$a<=>$b} keys %{$A2->{'n'}{$lang1}{$id1}{$lang2}}) {
          if(!defined($A1->{'n'}{$lang1}{$id1}{$lang2}{$id2})) {
              print STDERR "$A1->{fn}\tmissing alignment:\t$lang1 $id1  <-> $lang2 $id2\n";
          }
        }
      }
    }
  }

  my @L = qw(Source Final);
  foreach my $l (@L) {
    foreach my $id (sort {$a<=>$b} keys %{$A1->{$l}{D}}) {
      if(!defined($A2->{$l}{D}{$id})) {
        print STDERR "$A2->{$l}{fn}\tmissing id:\t$id\n"; 
        next;
      }
      foreach my $attr (sort  keys %{$A1->{$l}{D}{$id}}) {
        if(!defined($A2->{$l}{D}{$id}{$attr})) {
          print STDERR "$A2->{$l}{fn}\tmissing attribute:\t$attr\n"; 
          next;
        }
        if($A1->{$l}{D}{$id}{$attr} ne $A2->{$l}{D}{$id}{$attr}) { 
          printf STDERR "$A1->{$l}{fn}\tid:$id\tdifferent attribute values\t$attr:\tnew:\"%s\"\told:\"%s\"\n", $A2->{$l}{D}{$id}{$attr}, $A1->{$l}{D}{$id}{$attr};
          $A1->{$l}{D}{$id}{$attr} = $A2->{$l}{D}{$id}{$attr} = 1;
          next;
        }
      }
    }
  }

  foreach my $l (@L) {
    foreach my $id (sort {$a<=>$b} keys %{$A2->{$l}{D}}) {
      if(!defined($A1->{$l}{D}{$id})) {
        print STDERR "$A1->{$l}{fn}\tmissing id:\t$id\n";
        next;
      }
      foreach my $attr (sort  keys %{$A2->{$l}{D}{$id}}) {
        if(!defined($A1->{$l}{D}{$id}{$attr})) {
          print STDERR "$A1->{$l}{fn}\tid:$id\tmissing attribute:\t$attr\n";
          next;
        }
        if($A1->{$l}{D}{$id}{$attr} ne $A2->{$l}{D}{$id}{$attr}) {
          printf STDERR "$A1->{$l}{fn}\tid:$id\tdifferent attribute values\t$attr:\tnew:\"%s\"\told:\"%s\"\n", $A2->{$l}{D}{$id}{$attr}, $A1->{$l}{D}{$id}{$attr};
          next;
        }
      }
    }
  }
}

