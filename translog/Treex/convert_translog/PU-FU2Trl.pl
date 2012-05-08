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
  "Tokenisation of Translog file: \n".
  "  -T in:  Translog XML file <filename>\n".
  "     out: Write to STDOUT\n".
  "Options:\n".
  "  -f fixation unit gap \n".
  "  -p production unit gap \n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_f $opt_p $opt_T $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('T:f:p:v:h');

die $usage if defined($opt_h);

my $MaxFixGap = 400;
my $MaxKeyGap = 1000;
my $TRANSLOG = {};

my $KEY = undef;
my $FIX = undef;
my $FU = undef;
my $PU = undef;
my $Verbose = 0;

if (defined($opt_v)) {$Verbose = $opt_v;}
if (defined($opt_f)) {$MaxFixGap = $opt_f;}
if (defined($opt_p)) {$MaxKeyGap = $opt_p;}


### Read and Tokenize Translog log file
if (defined($opt_T)) {
  ReadTranslog($opt_T);
  FixationUnits();
  ProductionUnits();
  Parallel();
  UnitsTable();
  PrintTranslog();
  
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

## escape for R tables
sub Rescape {
  my ($in) = @_;

  $in =~ s/([ \t\n\r\f\#])/_/g;
# Hack  R does not understand unicode: all -> .
  $in =~ s/([^a-zA-Z0-9 '"_.;:|!@#$%^&*()+=\\|}{\[\]-])/./g;
#  $in =~ s/(.)/ToUniCode($1)/ego;

#  $in =~ s/([^\p{IsAlnum} '"_.;:|!@#$%^&*()+=\\|}{\[\]-])/./g;
  $in =~ s/(['"])/\\$1/g;
  return $in;
}

##########################################################
# Read Translog Logfile
##########################################################

## SourceText Positions
sub ReadTranslog {
  my ($fn) = @_;
  my ($type, $time, $cur);

  my $n = 0;

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");

  $type = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    $TRANSLOG->{$n++} = $_;

    if(/<Fixations>/) {$type =2; }
    elsif(/<Modifications>/) {$type =3; }
    elsif(/<FinalText>/) {$type =5; }
	
    if($type == 2 && /<Fix /) {
#printf STDERR "Translog: %s",  $_;
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/win="([-0-9][0-9]*)"/)  {$FIX->{$time}{'win'} = $1;}
      if(/dur="([0-9][0-9]*)"/)  {$FIX->{$time}{'dur'} = $1;}
      if(/cur="([-0-9][0-9]*)"/) {$FIX->{$time}{'cur'} = $1;}
      if(/id="([-0-9][0-9]*)"/)  {$FIX->{$time}{'id'} = $1;}
      if(/sid="([-0-9][0-9]*)"/) {$FIX->{$time}{'sid'} = $1;}

    }
    elsif($type == 3 && /<Mod /) {
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/cur="([0-9][0-9]*)"/)  {$KEY->{$time}{'cur'} = $1;}
      if(/chr="([^"]*)"/)        {$KEY->{$time}{'char'} = $1;}
      if(/type="([^"]*)"/)       {$KEY->{$time}{'type'} = $1;}
      if(/sid="([-0-9][0-9]*)"/)  {$KEY->{$time}{'sid'} = $1;}
      if(/id="([-0-9][0-9]*)"/)  {$KEY->{$time}{'id'} = $1;}
    }

    if(/<\/Modifications>/) {$type =0; }
    if(/<\/Fixations>/) {$type =0; }
  }
  close(FILE);
}

##### FIXATION UNITS 

sub FixationUnits {

  my $start = 0;
  my $end = 0;
  my $win = 0;
  my $FUlength = 0;
  my $SID = {};
  my $ID = {};

  foreach my $t (sort  {$a <=> $b} keys %{$FIX}) {
#printf STDERR "AAAAA\n";
#d($FIX->{$t});
    if($FIX->{$t}{'win'} <= 0 ) { next;}

    if($start != 0 && ((($t - $end) > $MaxFixGap) || ($FIX->{$t}{'win'} != $win))) {
      if($FUlength > 2 ) { 
        my $sid = "";
        my $id = "";
        my $n =0;
        foreach my $s (sort  {$a <=> $b} keys %{$SID}) { if($n++>0) {$sid .= "+";} $sid .= "$s"; } 
        $n =0;
        foreach my $s (sort  {$a <=> $b} keys %{$ID}) { if($n++>0) {$id .= "+";} $id .= "$s"; } 
        $FU->{$start}{dur} =$end - $start;
        $FU->{$start}{pause} =$t - $end;
        $FU->{$start}{win} =$win;
        $FU->{$start}{id} =$id;
        $FU->{$start}{sid} =$sid;
      }
      $start = 0;
    }
    if($start == 0) {$SID = {}; $ID = {}; $start = $t;  $FUlength=0;}
    if(defined($FIX->{$t}{'id'})) {
      foreach my $i (split(/\+/, $FIX->{$t}{'id'})) {$ID->{$i}++; } 
    }
    if(defined($FIX->{$t}{'sid'})) {
      foreach my $i (split(/\+/, $FIX->{$t}{'sid'})) {$SID->{$i}++; } 
    }
    $end = $t + $FIX->{$t}{'dur'};
    $FUlength ++;
    $win = $FIX->{$t}{'win'};
  }
  my $sid = "";
  my $id = "";
  my $n =0;
  foreach my $s (sort  {$a <=> $b} keys %{$SID}) { if($n++>0) {$sid .= "+";} $sid .= "$s"; } 
  $n =0;
  foreach my $s (sort  {$a <=> $b} keys %{$ID}) { if($n++>0) {$id .= "+";} $id .= "$s"; } 
  $FU->{$start}{dur} =$end - $start;
  $FU->{$start}{pause} = 0;
  $FU->{$start}{win} =$win;
  $FU->{$start}{id} =$id;
  $FU->{$start}{sid} =$sid;
}

sub ProductionUnits {

  my $start = 0;
  my $end = 0;
  my $win = 0;
  my $type = 'ins';
  my ($unit, $ins, $del, $SRC, $TGT);

  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {

    if($type ne $KEY->{$t}{type} && $KEY->{$t}{type} eq 'ins') {  $unit .= ']';}

    if($start != 0 && ($t - $end) > $MaxKeyGap) {
#printf STDERR "$FUidx\t$start\t$dur\t$win\t$pause\t---\t$fix\n";
      my $src = "";
      my $tgt = "";
      my $n =0;
      foreach my $s (sort  {$a <=> $b} keys %{$SRC}) { if($n++>0) {$src .= "+";} $src .= "$s"; }
      $n =0;
      foreach my $s (sort  {$a <=> $b} keys %{$TGT}) { if($n++>0) {$tgt .= "+";} $tgt .= "$s"; }
      $PU->{$start}{unit} =$unit;
      $PU->{$start}{pause} =$t - $end;
      $PU->{$start}{dur} =$end - $start;
      $PU->{$start}{ins} =$ins;
      $PU->{$start}{del} =$del;
      $PU->{$start}{tgt} =$tgt;
      $PU->{$start}{src} =$src;
      $start = 0;
    }
    if($start == 0) {$start=$t; $ins=0; $del=0; $unit = '';  $SRC={}; $TGT={};}

    if($KEY->{$t}{type} eq 'ins') {$ins ++;}
    if($KEY->{$t}{type} eq 'del') {$del ++;}
    if($type ne $KEY->{$t}{type} && $KEY->{$t}{type} eq 'del') {  $unit .= '[';}
    $unit .= $KEY->{$t}{char};

    if(defined($KEY->{$t}{'id'})) { foreach my $i (split(/\+/, $KEY->{$t}{'id'})) {$TGT->{$i}++; } }
    if(defined($KEY->{$t}{'sid'})) { foreach my $i (split(/\+/, $KEY->{$t}{'sid'})) {$SRC->{$i}++; } }
    $type = $KEY->{$t}{type};
    $end = $t;
  }
  if($type eq 'del') {  $unit .= ']';}
  my $src = "";
  my $tgt = "";
  my $n =0;
  foreach my $s (sort  {$a <=> $b} keys %{$SRC}) { if($n++>0) {$src .= "+";} $src .= "$s"; }
  $n =0;
  foreach my $s (sort  {$a <=> $b} keys %{$TGT}) { if($n++>0) {$tgt .= "+";} $tgt .= "$s"; }
  $PU->{$start}{unit} =$unit;
  $PU->{$start}{pause} = 0;
  $PU->{$start}{dur} =$end - $start;
  $PU->{$start}{tgt} =$tgt;
  $PU->{$start}{src} =$src;
  $PU->{$start}{ins} =$ins;
  $PU->{$start}{del} =$del;
}

sub Parallel {
  my $m = 0;

  foreach my $fu (sort {$a<=>$b} keys %{$FU}) {
    my $common = 0;
    foreach my $pu (sort {$a<=>$b} keys %{$PU}) {
      if($pu+$PU->{$pu}{dur} < $fu) {next;}
      if($pu > $fu+$FU->{$fu}{dur}) {last;}

# printf STDERR "FU:%s--%s\tPU:%s--%s\t%s\n", $fu, $fu+$FU->{$fu}{dur}, $pu, $pu+$PU->{$pu}{dur}, $common;
      ## FU inside PU
      if($pu <= $fu && $pu+$PU->{$pu}{dur} >= $fu+$FU->{$fu}{dur}) {$common += $FU->{$fu}{dur};}
      ## PU overlap start of FU
      elsif($pu <= $fu && $pu+$PU->{$pu}{dur} < $fu+$FU->{$fu}{dur}) {$common += $pu+$PU->{$pu}{dur}-$fu;}
      ## PU overlap end of FU
      elsif($pu > $fu && $pu+$PU->{$pu}{dur} >= $fu+$FU->{$fu}{dur}) {$common += $fu+$FU->{$fu}{dur} - $pu;}
      ## PU inside FU
      elsif($pu > $fu && $pu+$PU->{$pu}{dur} < $fu+$FU->{$fu}{dur}) {$common += $PU->{$pu}{dur};}
      else { print STDERR "Parallel: Error2\n";}
    }

    if($common == 0) { $FU->{$fu}{paral} = 0;}
    else {$FU->{$fu}{paral} = sprintf("%4.2f", 100*$common/$FU->{$fu}{dur}); }
# printf STDERR "\tcommon: %s\n", $FU->{$fu}{paral};
  }

  foreach my $pu (sort {$a<=>$b} keys %{$PU}) {
    my $common = 0;
    foreach my $fu (sort {$a<=>$b} keys %{$FU}) {
      if($fu+$FU->{$fu}{dur} < $pu) {next;}
      if($fu > $pu+$PU->{$pu}{dur}) {last;}

# printf STDERR "FU:%s--%s\tPU:%s--%s\t%s\n", $fu, $fu+$FU->{$fu}{dur}, $pu, $pu+$PU->{$pu}{dur}, $common;
      ## FU inside PU
      if($fu <= $pu && $fu+$FU->{$fu}{dur} >= $pu+$PU->{$pu}{dur}) {$common += $PU->{$pu}{dur};}
      ## PU overlap start of FU
      elsif($fu <= $pu && $fu+$FU->{$fu}{dur} < $pu+$PU->{$pu}{dur}) {$common += $fu+$FU->{$fu}{dur}-$pu;}
      ## PU overlap end of FU
      elsif($fu > $pu && $fu+$FU->{$fu}{dur} >= $pu+$PU->{$pu}{dur}) {$common += $pu+$PU->{$pu}{dur} - $fu;}
      ## PU inside FU
      elsif($fu > $pu && $fu+$FU->{$fu}{dur} < $pu+$PU->{$pu}{dur}) {$common += $FU->{$fu}{dur};}
      else { print STDERR "Parallel: Error3\n";}
    }
    if($common == 0) { $PU->{$pu}{paral} = 0;}
    else {$PU->{$pu}{paral} = sprintf("%4.2f", 100*$common/$PU->{$pu}{dur});}

# printf STDERR "\tcommon: %s\n", $PU->{$pu}{paral};
  }
}


################################################
#  PRINTING
################################################

sub UnitsTable {
  my $m = 0;

  foreach my $i (sort {$b<=>$a} keys %{$TRANSLOG}) { if($TRANSLOG->{$i} =~ /<\/LogFile>/) {$m=$i;last; }}

  $TRANSLOG->{$m++} ="  <FixUnits>\n";

  foreach my $t (sort {$a<=>$b} keys %{$FU}) {
    $TRANSLOG->{$m++} = "    <FU start=\"$t\" win=\"$FU->{$t}{win}\" dur=\"$FU->{$t}{dur}\" pause=\"$FU->{$t}{pause}\" parallel=\"$FU->{$t}{paral}\" id=\"$FU->{$t}{id}\" src=\"$FU->{$t}{sid}\" />\n";
  }
  $TRANSLOG->{$m++} ="  </FixUnits>\n";

  $TRANSLOG->{$m++} ="  <ProdUnits>\n";
  foreach my $t (sort {$a<=>$b} keys %{$PU}) {
    $TRANSLOG->{$m++} = "    <PU start=\"$t\" dur=\"$PU->{$t}{dur}\" pause=\"$PU->{$t}{pause}\" parallel=\"$PU->{$t}{paral}\" ins=\"$PU->{$t}{ins}\" del=\"$PU->{$t}{del}\" src=\"$PU->{$t}{src}\" tgt=\"$PU->{$t}{tgt}\" str=\"$PU->{$t}{unit}\" />\n";
  }
  $TRANSLOG->{$m++} ="  </ProdUnits>\n";
  $TRANSLOG->{$m++} ="</LogFile>\n";
}

sub PrintTranslog{
  foreach my $k (sort {$a<=>$b} keys %{$TRANSLOG}) { print STDOUT "$TRANSLOG->{$k}"; }
}

