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
  "Write AU item tables to STDOUT: \n".
  "  -T in:  Translog XML file <filename>\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_T $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:p:v:h');

die $usage if defined($opt_h);

my $SRC = undef;
my $TGT = undef;
my $KEY = undef;
my $FIX = undef;
my $ALN = undef;
my $FU = undef;
my $PU = undef;
my $Verbose = 0;
        
my $MaxFixGap = 400;
my $MaxKeyGap = 1000;
my $SourceLang = '';
my $TargetLang = '';


if (defined($opt_v)) {$Verbose = $opt_v;}


### Read and Tokenize Translog log file
if (defined($opt_T)) {
  ReadTranslog($opt_T);
  if(!defined($ALN)) { printf STDERR "WARNING $opt_T is not aligned: No AU Target Token Table produced\n"; exit;}

  my $AU = TargetAU();
  TTProduction($AU);
  Parallel();
  CheckAUComplete($AU);
  PrintAU($opt_T, $AU);
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
  $in =~ s/(['"])/\\$1/g;
  return $in;
}

##########################################################
# Read Translog Logfile
##########################################################

## SourceText Positions
sub ReadTranslog {
  my ($fn) = @_;
  my ($type, $time, $id);

  my $n = 0;

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");

  $type = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Language/) {
      if(/source="([^"]*)"/) {$SourceLang = $1; }
      if(/target="([^"]*)"/) {$TargetLang = $1; }
    }
    elsif(/<Fixations/)    {$type = 2; }
    elsif(/<Modifications/){$type = 3; }
    elsif(/<FinalToken/)   {$type = 6; }
    elsif(/<SourceToken/)  {$type = 7; }
    elsif(/<Alignment/)    {$type = 8; }
	
    if($type == 7 && /<Token/) {
      if(/ id="([0-9][0-9]*)"/) {$id =$1;}
      if(/tok="([^"]*)"/)   {$SRC->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$SRC->{$id}{space} = Rescape(MSunescape($1));}
      if(/cur="([^"]*)"/)    {$SRC->{$id}{cur} = $1;}
    }
    if($type == 6 && /<Token/) {
      if(/ id="([0-9][0-9]*)"/) {$id =$1;}
      if(/tok="([^"]*)"/)   {$TGT->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$TGT->{$id}{space} = Rescape(MSunescape($1));}
      if(/cur="([^"]*)"/)    {$TGT->{$id}{cur} = $1;}
    }
    if($type == 8 && /<Align /) {
      my $tid;
      if(/sid="([^"]*)"/) {$id =$1;}
      if(/tid="([^"]*)"/) {$tid=$1;}
      $ALN->{sid}{$id}{id}{$tid} = 1;
      $ALN->{tid}{$tid}{id}{$id} = 1;
    }
    elsif($type == 2 && /<Fix /) {
#printf STDERR "Translog: %s",  $_;
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/win="([^"]*)"/)        {$FIX->{$time}{'win'} = $1;}
      if(/dur="([0-9][0-9]*)"/)  {$FIX->{$time}{'dur'} = $1;}
      if(/cur="([-0-9][0-9]*)"/) {$FIX->{$time}{'cur'} = $1;}
      if(/tid="([^"]*)"/)        {$FIX->{$time}{'id'} = $1;}
      if(/sid="([^"]*)"/)        {$FIX->{$time}{'sid'} = $1;}
      if($FIX->{$time}{'sid'} eq '') {$FIX->{$time}{'sid'} = -1;}
      if(!defined($FIX->{$time}{'cur'})) { print STDERR "WARNING no char in Mod\t$_";}

    }
    elsif($type == 3 && /<Mod /) {
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/cur="([0-9][0-9]*)"/)  {$KEY->{$time}{'cur'} = $1;}
      if(/chr="([^"]*)"/)        {$KEY->{$time}{'char'} = Rescape(MSunescape($1));}
      if(/type="([^"]*)"/)       {$KEY->{$time}{'type'} = $1;}
      if(/tid="([^"]*)"/)        {$KEY->{$time}{'tid'} = $1;}
      if(/sid="([^"]*)"/)        {$KEY->{$time}{'sid'} = $1;}
      if($KEY->{$time}{'sid'} eq '') {$KEY->{$time}{'sid'} = -1;}
    }
#    <PU start="10685" dur="7049" pause="2719" parallel="69.1587" ins="34" del="0" src="3+4" tgt="1+3+4" str="Mordersygeplejerske&nbsp;modtager&nbsp;fire&nbsp;" />


    if(/<\/SourceToken>/)  {$type = 0; }
    if(/<\/FinalToken>/)   {$type = 0; }
    if(/<\/Fixations>/)    {$type = 0; }
    if(/<\/Modifications>/){$type = 0; }
    if(/<\/Alignment>/)    {$type = 0; }
  }
  close(FILE);
}

#################################################
sub TargetAU {
  my ($AU);

  if(!defined($ALN)) { return 0;}

  my $au = 0;
  foreach my $tid (sort  {$a <=> $b} keys %{$ALN->{tid}}) {
    if(defined($ALN->{tid}{$tid}{visited})) {next;}
    $ALN->{tid}{$tid}{visited}=1;

    foreach my $sid (sort {$a <=> $b} keys %{$ALN->{tid}{$tid}{id}}) {
      if(defined($SRC->{$sid}{visited})) {next;}
      $SRC->{$sid}{visited} = $au;

      if(defined($AU->{$au}{ss}) && $AU->{$au}{ss} ne '') {$AU->{$au}{ss} .= '_';}
      $AU->{$au}{ss} .= $SRC->{$sid}{tok};
      $AU->{$au}{sid}{$sid} ++;

      foreach my $tid2 (sort {$a <=> $b} keys %{$ALN->{sid}{$sid}{id}}) {
        if(defined($TGT->{$tid2}{visited})) {next;}
        $TGT->{$tid2}{visited} = $au;

        if(defined($AU->{$au}{ts}) && $AU->{$au}{ts} ne '') {$AU->{$au}{ts} .= '_';}
#print STDERR "TTTT: $tid2 $au\n";

        $AU->{$au}{ts} .= $TGT->{$tid2}{tok};
        $AU->{$au}{tid}{$tid2} ++;
      }
    }
    $au +=100;
  }
  foreach my $tid (sort  {$a <=> $b} keys %{$TGT}) {

#print STDERR "TTTT: $tid $au\n";
#d($TGT->{$tid});
    if(defined($TGT->{$tid}{visited})) { $au = $TGT->{$tid}{visited}; next;}
    while(defined($AU->{$au})) { $au++;}
#print STDERR "WARNING: too many AU gaps $au\n"; next;}
    $AU->{$au}{ts} = $TGT->{$tid}{tok};
    $AU->{$au}{ss} = "---";
    $AU->{$au}{tid}{$tid} =1;
    $AU->{$au}{sid}{-1} = 1;
  }
  return $AU;
} 

#################################################

sub TTProduction {
  my ($AU) = @_;

  my ($ins, $del, $len, $start, $end, $last, $au, $last_au) = 0;
  $ins=$del=$len=$start=$end=$last=$au=$last_au = 0;
  my $str = '';
  my $type = 'ins';

  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {
#d($KEY->{$t});
    my $tid = $KEY->{$t}{tid};
    AUs:
    foreach my $i (keys %{$AU}) { 
      foreach my $j (keys %{$AU->{$i}{tid}}) { 
        if($j == $tid) { $au = $i; last AUs;}
      }
    }

#printf STDERR "AAAAA1 $au $last_au $t $str\n";

    if($start > 0 && $au != $last_au) {
#printf STDERR "AAAAA2 $start \n";

      if(!defined($AU->{$last_au}{prod}) || $AU->{$last_au}{prod} == 0) {
        $AU->{$last_au}{pause} += $start - $last;
        $AU->{$last_au}{prod} += $end - $start;
        $AU->{$last_au}{prod2} = 0;
        $AU->{$last_au}{pause2} = 0;
      }
      else {
        $AU->{$last_au}{prod2} += $end - $start;
        $AU->{$last_au}{pause2} += $start - $last;
      }
      push(@{$AU->{$last_au}{start}}, $start);
      push(@{$AU->{$last_au}{end}}, $end);
      push(@{$AU->{$last_au}{last}}, $last);
      if($type eq 'del') {$str .= ']';}

      $AU->{$last_au}{ins} += $ins;
      $AU->{$last_au}{del} += $del;
      $AU->{$last_au}{len} += $len;
      $AU->{$last_au}{str} .= $str;
      $ins=0; $del=0; $len=0;
      $last = $end;
      $start = $t;
      $str = '';
      $type='ins'; 
    }

    if($KEY->{$t}{type} eq 'ins') {
      if($type ne 'ins') {$str .= ']';}
      $ins++;
    }
    else {
      if($type ne 'del') {$str .= '[';}
      $del++;
    }
    $str .= $KEY->{$t}{char};
    $len++;

    if($start == 0) { $start = $t; }
    $end = $t;
    $last_au = $au;
    $type =$KEY->{$t}{type};
  }
  if(!defined($AU->{$last_au}{prod}) || $AU->{$last_au}{prod} == 0) {
    $AU->{$last_au}{pause} += $start - $last;
    $AU->{$last_au}{prod} += $end - $start;
    $AU->{$last_au}{prod2} = 0;
    $AU->{$last_au}{pause2} = 0;
  }
  else {
    $AU->{$last_au}{prod2} += $end - $start;
    $AU->{$last_au}{pause2} += $start - $last;
  }
  $AU->{$last_au}{ins} += $ins;
  $AU->{$last_au}{del} += $del;
  $AU->{$last_au}{len} += $len;
  $AU->{$last_au}{str} .= $str;

}


sub Parallel {
  my $m = 0;

  foreach my $pu (sort {$a<=>$b} keys %{$TGT}) {
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
    if($common == 0) { $PU->{$pu}{par} = 0;}
    else {$PU->{$pu}{par} = sprintf("%4.2f", 100*$common/$PU->{$pu}{dur});}

# printf STDERR "\tcommon: %s\n", $PU->{$pu}{par};
  }
}

sub CheckAUComplete {
  my ($AU) = @_;

  foreach my $au (sort {$a<=>$b} keys %{$AU}) {
    if(!defined($AU->{$au}{ss}) || $AU->{$au}{ss} eq '') { $AU->{$au}{ss} = '---';}
    if(!defined($AU->{$au}{ts}) || $AU->{$au}{ts} eq '') { $AU->{$au}{ts} = '---';}
    if(!defined($AU->{$au}{str}) || $AU->{$au}{str} eq '') {$AU->{$au}{str} = '---';}
    if(!defined($AU->{$au}{len})) {$AU->{$au}{len} = 0;}
    if(!defined($AU->{$au}{ins})) {$AU->{$au}{ins} = 0;}
    if(!defined($AU->{$au}{del})) {$AU->{$au}{del} = 0;}
    if(!defined($AU->{$au}{prod})) {$AU->{$au}{prod} = 0;}
    if(!defined($AU->{$au}{pause})){$AU->{$au}{pause} = 0;}
    if(!defined($AU->{$au}{prod2})) {$AU->{$au}{prod2} = 0;}
    if(!defined($AU->{$au}{pause2})) {$AU->{$au}{pause2} = 0;}
  }
}
 

################################################################
## Print table with (wnr, token) 

sub PrintAU {
  my ($fn, $AU) = @_;
  my ($f, $s);
  my $n = 1;

  $fn =~ s/^.*\///g;
  $fn =~ s/.Event.xml//;

  printf STDOUT "AUid\tAUtarget\tAUsource\tSL\tTL\tFile\tLength\tInsertion\tDeletion\tTime1\tPause1\tTime2\tPause2\tTyped\n";
  foreach $f (sort {$a <=> $b} keys %{$AU}) {

#print STDERR "TTTT\n";
#d($AU->{$f});

    if(!defined($AU->{$f}{'ts'})) { next;}

    printf STDOUT "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
      $n++,
      $AU->{$f}{'ts'},
      $AU->{$f}{'ss'},
      $SourceLang,
      $TargetLang,
      $fn, 
      $AU->{$f}{'len'},
      $AU->{$f}{'ins'}, 
      $AU->{$f}{'del'},
      $AU->{$f}{'prod'}, 
      $AU->{$f}{'pause'}, 
      $AU->{$f}{'prod2'},
      $AU->{$f}{'pause2'},
      $AU->{$f}{'str'};
      
  }
}

