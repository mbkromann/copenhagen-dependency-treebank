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

my $MaxFixGap = 400;
my $MaxKeyGap = 1000;

my $usage =
  "Extract R tables from Translog file: \n".
  "  -T in:  Translog XML file <filename>\n".
  "  -O out: Write output   <filename>.{kd,fd,fu,pu,st}\n".
  "Options:\n".
  "  -f min fixation unit boundary [$MaxFixGap]\n".
  "  -p min production unit boundary [$MaxKeyGap]\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_O $opt_T $opt_f $opt_p $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:p:k:v:h');

die $usage if defined($opt_h);

my $SRC = undef;
my $TGT = undef;
my $KEY = undef;
my $FIX = undef;
my $ALN = undef;
my $FU = undef;
my $PU = undef;
my $AU = undef;
my $SourceLang = '';
my $TargetLang = '';
my $Text = '';
my $Task = '';
my $Part = '';
my $SessionDuration = 0;
my $DraftingStart = 0;
my $DraftingEnd = 0;

my $Verbose = 0;
        
if (defined($opt_v)) {$Verbose = $opt_v;}
if (defined($opt_p)) {$MaxKeyGap = $opt_p;}
if (defined($opt_f)) {$MaxFixGap = $opt_f;}


### Read and Tokenize Translog log file
if (defined($opt_T) && defined($opt_O)) {
  if(ReadTranslog($opt_T) == 0) {
    print STDERR "Trl2ProgGraphTables.pl WARNING: no process data in $opt_T\n";
    exit;
  }

  if($SourceLang eq '' || $TargetLang eq '') { 
    print STDERR "ERROR $opt_T no language specified\n";
    exit;
  }

  my ($study,$rec) = $opt_T =~ /.*\/([^\/]*)\/Events\/([^.]*)\.Event.xml/;
#print STDERR "XXX $study $rec\n";
 
  ($Part, $Task, $Text) = $rec =~/([^_]*)_([A-Z]*)([0-9]*)/;
  $Text = $study."-".$Text;
  $Part = $study."-".$Part;
  SessionInfo();

  if(defined($ALN)) { 
    MakeAlignUnits();
    AlignmentUnits('au');
    CrossingAlignmentUnits();
  }
  if(!defined($FU)) { FixationUnits();}
  if(!defined($PU)) { ProductionUnits();}
  TargetTokenUnits();
  CrossingTargetToken();

  MakeSourceUnits();
  AlignmentUnits('st');

  CrossingSourceToken();
  ParallelActivity();

  PrintFU("$opt_O.fu");
  PrintPU("$opt_O.pu");
  PrintFD("$opt_O.fd");
  PrintKD("$opt_O.kd");
  PrintST("$opt_O.st");
  PrintAU("$opt_O.au");
  PrintTT("$opt_O.tt");
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

  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");

  $type = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<System / && /Value="STOP"/) {
      if(/Time="([^"]*)"/) {$SessionDuration = $1; }
    }
    if(/<Language/i) {
      if(/source="([^"]*)"/i) {$SourceLang = $1; }
      if(/target="([^"]*)"/i) {$TargetLang = $1; }
    }

    elsif(/<SourceToken/)  {$type = 1; }
    elsif(/<Fixations/)    {$type = 2; }
    elsif(/<Modifications/){$type = 3; }
    elsif(/<Alignment/)    {$type = 4; }
    elsif(/<FinalToken/)   {$type = 6; }
	
    if($type == 1 && /<Token/) {
      if(/ id="([^"]*)"/)   {$id = $1;}
      if(/cur="([^"]*)"/)   {$SRC->{$id}{cur} = $id;}
      if(/tok="([^"]*)"/)   {$SRC->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$SRC->{$id}{space} = Rescape(MSunescape($1));}
    }
    if($type == 6 && /<Token/) {
      if(/ id="([0-9][0-9]*)"/) {$id =$1;}
      if(/tok="([^"]*)"/)   {$TGT->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$TGT->{$id}{space} = Rescape(MSunescape($1));}
      if(/cur="([^"]*)"/)    {$TGT->{$id}{cur} = $1;}
    }
    elsif($type == 2 && /<Fix /) {
#printf STDERR "Translog: %s",  $_;
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/win="([^"]*)"/)        {$FIX->{$time}{'win'} = $1;}
      if(/dur="([0-9][0-9]*)"/)  {$FIX->{$time}{'dur'} = $1;}
      if(/cur="([-0-9][0-9]*)"/) {$FIX->{$time}{'cur'} = $1;}
      if(/tid="([^"]*)"/)        {$FIX->{$time}{'tid'} = $1;}
      if(/sid="([^"]*)"/)        {$FIX->{$time}{'sid'} = $1;}
      if($FIX->{$time}{'sid'} eq '') {$FIX->{$time}{'sid'} = -1;}
      if($FIX->{$time}{'tid'} eq '') {$FIX->{$time}{'tid'} = -1;}
      $n += 1;

    }
    elsif($type == 3 && /<Mod /) {
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/cur="([0-9][0-9]*)"/)  {$KEY->{$time}{'cur'} = $1;}
      if(/chr="([^"]*)"/)        {$KEY->{$time}{'char'} = Rescape(MSunescape($1));}
      if(/type="([^"]*)"/)       {$KEY->{$time}{'type'} = $1;}
      if(/tid="([^"]*)"/)        {$KEY->{$time}{'tid'} = $1;}
      if(/sid="([^"]*)"/)        {$KEY->{$time}{'sid'} = $1;}
      if($KEY->{$time}{'sid'} eq '') {$KEY->{$time}{'sid'} = -1;}
      if($KEY->{$time}{'tid'} eq '') {$KEY->{$time}{'tid'} = -1;}
      $n += 2;
    }

    if($type == 4 && /<Align /) {
      my $tid;
      if(/sid="([^"]*)"/) {$id =$1;}
      if(/tid="([^"]*)"/) {$tid=$1;}
      $ALN->{sid}{$id}{id}{$tid} = 1;
      $ALN->{tid}{$tid}{id}{$id} = 1;
    }

    if(/<\/SourceToken>/)  {$type = 0; }
    if(/<\/Fixations>/)    {$type = 0; }
    if(/<\/Modifications>/){$type = 0; }
  }
  close(FILE);
  return $n;
}


#################################################
# Orientation, Drafting Revision
#################################################

sub SessionInfo {

  my $tid = 0;
  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {
    if($DraftingStart <= 0) {$DraftingStart = $t;}
    if($KEY->{$t}{'tid'} > $tid) {$tid=$KEY->{$t}{'tid'}; $DraftingEnd = $t;}
#printf STDERR "AAA1: %s %s %s\n", $SessionDuration, $DraftingStart, $DraftingEnd;
} }


#################################################
# UNITS 
#################################################
##### FIXATION UNITS 

sub FixationUnits {

  my $start = 0;
  my $end = 0;
  my $win = 0;
  my $FUlength = 0;
  my $path ='';

  foreach my $t (sort  {$a <=> $b} keys %{$FIX}) {
#printf STDERR "AAAAA\n";
#d($FIX->{$t});
    if($FIX->{$t}{'win'} <= 0 ) { next;}

    if($start != 0 && (($t - $end) > $MaxFixGap)) {
      if($FUlength > 2 ) { 
        $FU->{$start}{dur} =$end - $start;
        $FU->{$start}{pause} =$t - $end;
        $FU->{$start}{win}  =$win;
        $FU->{$start}{path} =$path;
#printf STDERR "AAAAA\n";
#d($FU->{$start});
      }
      $start = 0;
    }
    if($start == 0) {$path =''; $start = $t;  $FUlength=0;}
    if($FIX->{$t}{'win'}  == 2 && defined($FIX->{$t}{'tid'})) { $path .= "2:$FIX->{$t}{'tid'}+"; }
    if($FIX->{$t}{'win'}  == 1 && defined($FIX->{$t}{'sid'})) { $path .= "1:$FIX->{$t}{'sid'}+"; }
    $end = $t + $FIX->{$t}{'dur'};
    $FUlength ++;
    $win = $FIX->{$t}{'win'};
  }
  if($end > 0) {
    $FU->{$start}{dur} =$end - $start;
    $FU->{$start}{pause} = 0;
    $FU->{$start}{win} =$win;
    $FU->{$start}{path} =$path;
  }
}

sub ProductionUnits {

  my $start = 0;
  my $end = 0;
  my $win = 0;
  my $type = 'ins';
  my ($str, $ins, $del, $SRCbuf, $TGTbuf);

  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {

    if($type ne $KEY->{$t}{type} && $KEY->{$t}{type} eq 'ins') {  $str .= ']';}

    if($start != 0 && ($t - $end) > $MaxKeyGap) {
#printf STDERR "$FUidx\t$start\t$dur\t$win\t$pause\t---\t$fix\n";
      my $src = "";
      my $tgt = "";
      my $n =0;
      foreach my $s (sort  {$a <=> $b} keys %{$SRCbuf}) { if($n++>0) {$src .= "+";} $src .= "$s"; }
      $n =0;
      foreach my $s (sort  {$a <=> $b} keys %{$TGTbuf}) { if($n++>0) {$tgt .= "+";} $tgt .= "$s"; }
      $PU->{$start}{str} =$str;
      $PU->{$start}{pause} =$t - $end;
      $PU->{$start}{dur} =$end - $start;
      $PU->{$start}{ins} =$ins;
      $PU->{$start}{del} =$del;
      $PU->{$start}{tid} =$tgt;
      $PU->{$start}{sid} =$src;
      $start = 0;
    }
    if($start == 0) {$start=$t; $ins=0; $del=0; $str = '';  $SRCbuf={}; $TGTbuf={};}

    if($KEY->{$t}{type} eq 'ins') {$ins ++;}
    if($KEY->{$t}{type} eq 'del') {$del ++;}
    if($type ne $KEY->{$t}{type} && $KEY->{$t}{type} eq 'del') {  $str .= '[';}
    $str .= $KEY->{$t}{char};

    if(defined($KEY->{$t}{'tid'})) { foreach my $i (split(/\+/, $KEY->{$t}{'tid'})) {$TGTbuf->{$i}++; } }
    if(defined($KEY->{$t}{'sid'})) { foreach my $i (split(/\+/, $KEY->{$t}{'sid'})) {$SRCbuf->{$i}++; } }
    $type = $KEY->{$t}{type};
    $end = $t;
  }
  if($type eq 'del') {  $str .= ']';}
  my $src = "";
  my $tgt = "";
  my $n =0;
  foreach my $s (sort  {$a <=> $b} keys %{$SRCbuf}) { if($n++>0) {$src .= "+";} $src .= "$s"; }
  $n =0;
  foreach my $s (sort  {$a <=> $b} keys %{$TGTbuf}) { if($n++>0) {$tgt .= "+";} $tgt .= "$s"; }
  $PU->{$start}{str} =$str;
  $PU->{$start}{pause} = 0;
  $PU->{$start}{dur} =$end - $start;
  $PU->{$start}{tid} =$tgt;
  $PU->{$start}{sid} =$src;
  $PU->{$start}{ins} =$ins;
  $PU->{$start}{del} =$del;
}


### Mapping von TargetToken ID nach AU ID
my  $Tid2AU = {};
my  $Tid2Sid = {};

sub MakeAlignUnits {

  if(!defined($ALN)) { return 0;}

  my $au = 0;
  foreach my $tid (sort  {$a <=> $b} keys %{$ALN->{tid}}) {
    if(defined($ALN->{tid}{$tid}{visited})) {next;}
    $ALN->{tid}{$tid}{visited}=$au;

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

## unaligned TGT Token
  $au = 0;
  foreach my $tid (sort  {$a <=> $b} keys %{$TGT}) {
#print STDERR "TTTT: $tid $au\n";
#d($TGT->{$tid});
    if(defined($TGT->{$tid}{visited})) { $au = $TGT->{$tid}{visited}; }
    else {
      while(defined($AU->{$au})) { $au++;}
  #print STDERR "WARNING: too many AU gaps $au\n"; next;}
      $AU->{$au}{ts} = $TGT->{$tid}{tok};
      $AU->{$au}{ss} = "---";
      $AU->{$au}{tid}{$tid} =1;
      $AU->{$au}{sid}{-1} = 1;
    }
    $Tid2AU->{$tid} = $au;
  }

  return 1;
}

sub MakeSourceUnits {

  if(!defined($ALN)) { return 0;}

  foreach my $sid (sort  {$a <=> $b} keys %{$SRC}) {
    if(defined($ALN->{sid}{$sid})) {
      my $str = '';
      foreach my $tid (sort  {$a <=> $b} keys %{$ALN->{sid}{$sid}{id}}) {

        $SRC->{$sid}{tid}{$tid} ++;
        $Tid2Sid->{$tid} = $sid;
        if($str ne '') {$str .= '_';}
        $str .= $TGT->{$tid}{tok};
      }
      $SRC->{$sid}{ttok} = $str;
    }
  }
}

sub UnitFeatures {
  my ($U, $start, $end, $last, $ins, $del, $len, $str) = @_;

  if(!defined($U->{time1}) || $U->{time1} == 0) {
    $U->{time1} = $start;
    $U->{dur1} = $end - $start;
    $U->{pause1} = $start - $last;
    $U->{unit1} = $str;
    $U->{time2} = 0;
  }
  elsif(!defined($U->{time2}) || $U->{time2} == 0) {
    $U->{time2} = $start;
    $U->{dur2} = $end - $start;
    $U->{pause2} = $start - $last;
    $U->{unit2} = $str;
  }
  push(@{$U->{start}}, $start);
  push(@{$U->{end}}, $end);
  push(@{$U->{last}}, $last);
  push(@{$U->{unit}}, $str);

  $U->{dur} += $end - $start;
  $U->{pause} += $start - $last;
  $U->{ins} += $ins;
  $U->{del} += $del;
  $U->{len} += $len;
  $U->{str} .= $str;
}

sub AlignmentUnits {
  my ($U) = @_;

  my ($ins, $del, $len, $start, $end, $last, $u, $last_u) = 0;
  $ins=$del=$len=$start=$end=$last=$u=$last_u = 0;
  my $str = '';
  my $type = 'ins';

  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {
#d($KEY->{$t});
    my $tid = $KEY->{$t}{tid};
    if($U eq 'au') {$u=$Tid2AU->{$tid};}
    elsif(defined($Tid2Sid->{$tid})) {$u=$Tid2Sid->{$tid};}
    else {$u = undef;}

# printf STDERR "AlignmentUnits Tok:$tid\t$TGT->{$tid}{tok}\t$u:$AU->{$u}{ts}\tkey:$KEY->{$t}{char}\t$start\n";
# if($u == 400) {printf STDERR "AlignmentUnits $u $AU->{$u}{ts} $start\n";}

    if(!defined($u) || !defined($last_u) ||  ($start > 0 && $u != $last_u)) {
#printf STDERR "AAAAA2 $start \n";

      if($type eq 'del') {$str .= ']';}

      if(defined($last_u)) {
        if($U eq 'au') {UnitFeatures($AU->{$last_u}, $start, $end, $last, $ins, $del, $len, $str);}
        else { UnitFeatures($SRC->{$last_u}, $start, $end, $last, $ins, $del, $len, $str);}
      }

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
    $last_u = $u;
    $type =$KEY->{$t}{type};
  }
  if($type eq 'del') {$str .= ']';}

  if(defined($last_u)) {
    if($U eq 'au') {UnitFeatures($AU->{$last_u}, $start, $end, $last, $ins, $del, $len, $str);}
    else { UnitFeatures($SRC->{$last_u}, $start, $end, $last, $ins, $del, $len, $str);}
  }
}

#################################################

sub TargetTokenUnits {

  my ($ins, $del, $len, $start, $end, $last, $id) = 0;
  $ins=$del=$len=$start=$end=$last=$id = 0;
  my $str = '';
  my $type = 'ins';

  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {
#printf STDERR "AAAAA\n";
#d($KEY->{$t});

    if($start > 0 && $KEY->{$t}{tid} != $id) {
      if($type eq 'del') {$str .= ']';}
      UnitFeatures($TGT->{$id}, $start, $end, $last, $ins, $del, $len, $str);

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
    $id = $KEY->{$t}{tid};
    $type =$KEY->{$t}{type};
  }
  if($type eq 'del') {$str .= ']';}
  UnitFeatures($TGT->{$id}, $start, $end, $last, $ins, $del, $len, $str);
}


##################################################
#  Crossing Reading/writing activity
##################################################

sub CrossingSourceToken {

  if(!defined($ALN)) {return;}

  my $lastTid = -1;
  my $lastSid = 0;
  my $tid = 0;
  foreach my $sid (sort {$a<=>$b} keys %{$SRC}) {
#    $sid=$lastSid;
    if($lastSid == -1) {
      if(defined($ALN->{sid}{$sid})) {
        foreach my $id (keys %{$ALN->{sid}{$sid}{id}}) {
          if(abs($id-$lastTid) > abs($tid-$lastTid)) { $tid = $id;}
#          printf STDERR "AAA1: tid:$tid id:$id sid:$sid\n";
      } }
      $SRC->{$sid}{cross} = $tid - $lastTid;
#      printf STDERR "CrossingTargetToken: lastTid:$tid lastSid:$lastSid\tdiff:%s\n", $sid-$lastSid;
    }

    else {
      if(defined($ALN->{sid}{$sid})) {
        foreach my $id (keys %{$ALN->{sid}{$sid}{id}}) {
          if(abs($id-$lastTid) > abs($tid-$lastTid)) { $tid = $id;}
#          printf STDERR "AAA2: tid:$tid id:$id sid:$sid\n";
      } }
#      else { printf STDERR "NOO2 tid:$tid\n";}
      $SRC->{$sid}{cross} = $tid - $lastTid;
#      printf STDERR "CrossingTargetToken: lastTid:$tid lastSid:$lastSid\tdiff:%s\n", $sid-$lastSid;
    }

    $lastSid = $sid;
    $lastTid = $tid;

  }
}

sub CrossingTargetToken {

  if(!defined($ALN)) {return;}

  my $lastTid = -1;
  my $lastSid = 0;
  my $sid = 0;
  foreach my $tid (sort {$a<=>$b} keys %{$TGT}) {
#    $sid=$lastSid;
    if($lastTid == -1) {
      if(defined($ALN->{tid}{$tid})) {
        foreach my $id (keys %{$ALN->{tid}{$tid}{id}}) {
          if(abs($id-$lastSid) > abs($sid-$lastSid)) { $sid = $id;}
#          printf STDERR "AAA1: tid:$tid id:$id sid:$sid\n";
      } } 
      $TGT->{$tid}{cross} = $sid - $lastSid;
#      printf STDERR "CrossingTargetToken: lastTid:$tid lastSid:$lastSid\tdiff:%s\n", $sid-$lastSid;
    }

    else {
      if(defined($ALN->{tid}{$tid})) {
        foreach my $id (keys %{$ALN->{tid}{$tid}{id}}) {
          if(abs($id-$lastSid) > abs($sid-$lastSid)) { $sid = $id;}
#          printf STDERR "AAA2: tid:$tid id:$id sid:$sid\n";
      } } 
#      else { printf STDERR "NOO2 tid:$tid\n";}
      $TGT->{$tid}{cross} = $sid - $lastSid;
#      printf STDERR "CrossingTargetToken: lastTid:$tid lastSid:$lastSid\tdiff:%s\n", $sid-$lastSid;
    }

    $lastTid = $tid;
    $lastSid = $sid;

  }
}

sub CrossingAlignmentUnits {

  if(!defined($ALN)) {return;}

  my $lastTid = -1;
  my $lastSid = 0;
  my ($smin, $smax, $tmin, $tmax);
  foreach my $au (sort {$a<=>$b} keys %{$AU}) {
    $smin=$tmin=10000;
    $smax=$tmax=0;
    if($lastTid == -1) {
      foreach my $tid (sort {$a<=>$b} keys %{$AU->{$au}{tid}}) {
        if($tmax < $tid) { $tmax = $tid;}
        if($tmin > $tid) { $tmin = $tid;}
        if(defined($ALN->{tid}{$tid})) {
          foreach my $id (keys %{$ALN->{tid}{$tid}{id}}) {
            if($smax < $id) { $smax = $id;}
            if($smin > $id) { $smin = $id;}
#            if(abs($id-$lastSid) > abs($sid-$lastSid)) { $sid = $id;}
#            printf STDERR "AAA1: tid:$tid\tsmin:$smin, smax:$smax, tmin:$tmin tmax:$tmax\n";
        } } 
        else { 
          $smax=$lastSid; $smax=$smin-1;$tmax=$tmin-1;
#          printf STDERR "NOO2 tid:$tid\n";
        }
      }
      $AU->{$au}{cross} = "$smax-$lastSid.$smax-$smin+1.$tmax-$tmin+1";
#      printf STDERR "CrossingAU: au:$au lastSid:$lastSid sid:%s.%s.%s\n", $smax-$lastSid, $smax-$smin+1,$tmax-$tmin+1;
    }

    else {
      foreach my $tid (sort {$a<=>$b} keys %{$AU->{$au}{tid}}) {
        if(defined($ALN->{tid}{$tid})) {
        if($tmax < $tid) { $tmax = $tid;}
        if($tmin > $tid) { $tmin = $tid;}
          foreach my $id (keys %{$ALN->{tid}{$tid}{id}}) {
            if($smax < $id) { $smax = $id;}
            if($smin > $id) { $smin = $id;}
#            if(abs($id-$lastSid) > abs($sid-$lastSid)) { $sid = $id;}
#            printf STDERR "AAA1: tid:$tid\tsmin:$smin, smax:$smax, tmin:$tmin tmax:$tmax\n";
        } }
        else { 
          $smax=$lastSid; $smax=$smin-1;$tmax=$tmin-1;
#          printf STDERR "NOO2 tid:$tid\n";
        }
      }
      $AU->{$au}{cross} = "$smax-$lastSid.$smax-$smin+1.$tmax-$tmin+1";
#      printf STDERR "CrossingAU: au:$au tmax:$tmax lastSid:$lastSid sid:%s.%s.%s\n", $smax-$lastSid, $smax-$smin+1,$tmax-$tmin+1;
    }

    $lastTid = $tmax;
    $lastSid = $smax;

  }
}

##################################################
#  Parallel Reading/writing activity
##################################################

## amount of overlap between $start - $dur and intervals in $U
sub Overlap {
  my ($start, $dur, $U) = @_;
  my $m = 0;

  if($dur == 0) {
#    printf STDERR "WARNING Overlap: start:$start dur:$dur\n";
    return 0;
  }

  my $common = 0;
  foreach my $u (sort {$a<=>$b} keys %{$U}) {
    if($u+$U->{$u}{dur} < $start) {next;}
    if($u > $start+$dur) {last;}

# printf STDERR "U:%s--%s\tPU:%s--%s\t%s\n", $u, $u+$U->{$u}{dur}, $start, $start+$dur, $common;
    ## U inside PU
    if($u <= $start && $u+$U->{$u}{dur} >= $start+$dur) {$common += $dur;}
    ## PU overlap start of U
    elsif($u <= $start && $u+$U->{$u}{dur} < $start+$dur) {$common += $u+$U->{$u}{dur}-$start;}
    ## PU overlap end of U
    elsif($u > $start && $u+$U->{$u}{dur} >= $start+$dur) {$common += $start+$dur - $u;}
    ## PU inside U
    elsif($u > $start && $u+$U->{$u}{dur} < $start+$dur) {$common += $U->{$u}{dur};}
    else { print STDERR "Overlap: Error3\n";}
  }

#printf STDERR "Overlap: start:$start\t dur:$dur   \t over:$common \tinters:%4.4f\n", 100*$common/$dur;
  return 100*$common/$dur;
}


sub ParallelActivity {
  my $m = 0;

  foreach my $u (sort {$a<=>$b} keys %{$PU}) {
    $PU->{$u}{par} = sprintf("%4.2f",Overlap($u, $PU->{$u}{dur}, $FU));
  }
  foreach my $u (sort {$a<=>$b} keys %{$FU}) {
    $FU->{$u}{par} = sprintf("%4.2f",Overlap($u, $FU->{$u}{dur}, $PU));
  }

  foreach my $u (sort {$a<=>$b} keys %{$AU}) {
    $AU->{$u}{par1} = 0;
    $AU->{$u}{par2} = 0;
    for(my $i=0; $i<=$#{$AU->{$u}{start}}; $i++) {
      my $start = $AU->{$u}{start}[$i];
      my $dur   = $AU->{$u}{end}[$i] - $AU->{$u}{start}[$i];
      my $ov=Overlap($start, $dur, $FU);
      push(@{$AU->{$u}{par}}, $ov);
      if($i==0) {$AU->{$u}{par1} =sprintf("%4.2f", $ov);}
      if($i==1) {$AU->{$u}{par2} =sprintf("%4.2f", $ov);}
#printf STDERR "ParallelActivity au:$u i:$i ov:$ov start:$start dur:$dur\n";
#if($AU->{$u}{par2} eq "75.88") {
#printf STDERR "ParallelActivity xxxx\n";
#d($AU->{$u}{start});
#}
    }
  }

  foreach my $u (sort {$a<=>$b} keys %{$TGT}) {
#printf STDERR "ParallelActivity TT\n";
#d($TGT->{$u}{start});
    $TGT->{$u}{par1} = 0;
    $TGT->{$u}{par2} = 0;
    for(my $i=0; $i<=$#{$TGT->{$u}{start}}; $i++) {
      my $start = $TGT->{$u}{start}[$i];
      my $dur   = $TGT->{$u}{end}[$i] - $TGT->{$u}{start}[$i];
      my $ov=Overlap($start, $dur, $FU);
      push(@{$TGT->{$u}{par}}, $ov);
      if($i==0) {$TGT->{$u}{par1} = sprintf("%4.2f", $ov);}
      if($i==1) {$TGT->{$u}{par2} = sprintf("%4.2f", $ov);}
    }
  } 

  foreach my $u (sort {$a<=>$b} keys %{$SRC}) {
#printf STDERR "ParallelActivity TT\n";
#d($TGT->{$u}{start});
    $SRC->{$u}{par1} = 0;
    $SRC->{$u}{par2} = 0;
    for(my $i=0; $i<=$#{$SRC->{$u}{start}}; $i++) {
      my $start = $SRC->{$u}{start}[$i];
      my $dur   = $SRC->{$u}{end}[$i] - $SRC->{$u}{start}[$i];
      my $ov=Overlap($start, $dur, $FU);
      push(@{$SRC->{$u}{par}}, $ov);
      if($i==0) {$SRC->{$u}{par1} = sprintf("%4.2f", $ov);}
      if($i==1) {$SRC->{$u}{par2} = sprintf("%4.2f", $ov);}
    }
  }


}

################################################################
# PRINTING
################################################################

sub PrintKD {
  my ($fn) = @_;

  if(!defined( $KEY )) {
    printf STDERR "PrintKD: undefined Keyboard data \n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }

  my $n = 0;
#  printf STDERR "n\ttime\ttype\tcur\tchr\tsrc\ttgt\n";
  printf FILE "KEYid\tTime\tType\tCursor\tChar\tSTid\tTTid\n";
  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {
#    print STDERR "$n\t$t\t$KEY->{$t}{'type'}\t$KEY->{$t}{'cur'}\t$KEY->{$t}{'char'}\t$KEY->{$t}{'tid'}\t$KEY->{$t}{'sid'}\n";
    print FILE "$n\t$t\t$KEY->{$t}{'type'}\t$KEY->{$t}{'cur'}\t$KEY->{$t}{'char'}\t$KEY->{$t}{'sid'}\t$KEY->{$t}{'tid'}\n";
    $n++;
  }
  close (FILE);
}

sub PrintFD {
  my ($fn) = @_;

  if(!defined( $FIX )) {
    printf STDERR "PrintFD: undefined Keyboard data \n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }

  my $n = 0;
  printf FILE "FIXid\tTime\tWin\tDur\tChar\tSTid\tTTid\n";
#  printf STDERR "n\ttime\twin\tdur\tcur\tid\tsid\n";

  foreach my $t (sort  {$a <=> $b} keys %{$FIX}) {
    my $SID = [split(/\+/, $FIX->{$t}{'sid'})];
#print STDERR "$n\t$t\t$FIX->{$t}{'win'}\t$FIX->{$t}{'dur'}\t$FIX->{$t}{'cur'}\t$FIX->{$t}{'tid'}\t$FIX->{$t}{'sid'}\n";
#d($FIX->{$t});
    print FILE "$n\t$t\t$FIX->{$t}{'win'}\t$FIX->{$t}{'dur'}\t$FIX->{$t}{'cur'}\t$SID->[0]\t$FIX->{$t}{'tid'}\n";
    $n++;
  }
  close (FILE);
}


sub PrintFU {
  my ($fn) = @_;

  if(!defined( $FU )) {
    printf STDERR "PrintFU: undefined Keyboard data \n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }

  my $n = 0;
  printf FILE "FUid\tTime\tWin\tDur\tPause\tParal\tPath\n";

  foreach my $t (sort  {$a <=> $b} keys %{$FU}) {
#print STDERR "$n\t$t\t$FU->{$t}{'dur'}\t$FU->{$t}{'win'}\t$FU->{$t}{'pause'}\t$FU->{$t}{'par'}\t$FU->{$t}{'id'}\n";
#d($FU->{$t});
    print FILE "$n\t$t\t$FU->{$t}{'win'}\t$FU->{$t}{'dur'}\t$FU->{$t}{'pause'}\t$FU->{$t}{'par'}\t$FU->{$t}{'path'}\n";
    $n++;
  }
  close (FILE);
}

sub PrintPU {
  my ($fn) = @_;

  if(!defined( $PU )) {
    printf STDERR "PrintPU: undefined Keyboard data \n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }

  my $n = 0;
  printf FILE "PUid\tTime\tDur\tPause\tParal\tIns\tDel\tSTid\tTTid\tTyped\n";

  foreach my $t (sort  {$a <=> $b} keys %{$PU}) {
    print FILE "$n\t$t\t$PU->{$t}{'dur'}\t$PU->{$t}{'pause'}\t$PU->{$t}{'par'}\t$PU->{$t}{'ins'}\t$PU->{$t}{'del'}\t$PU->{$t}{'sid'}\t$PU->{$t}{'tid'}\t$PU->{$t}{'str'}\n";
    $n++;
  }
  close (FILE);
}

sub PrintAU {
  my ($fn) = @_;
  my $n = 1;

  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }

  printf FILE "AUid\tAUtarget\tAUsource\tSL\tTL\tPerson\tText\tTask\tSession\tDraft\tRevise\tUnit1\tTime1\tDur1\tPause1\tParal1\tUnit2\tTime2\tDur2\tPause2\tParal2\tLen\tIns\tDel\tDur\tTyped\n";

  foreach my $au (sort {$a <=> $b} keys %{$AU}) {

#print STDERR "TTTT\n";
#d($AU->{$f});

#    if(!defined($AU->{$f}{'ts'})) { next;}

    if(!defined($AU->{$au}{ss}) || $AU->{$au}{ss} eq '') { $AU->{$au}{ss} = '---';}
    if(!defined($AU->{$au}{ts}) || $AU->{$au}{ts} eq '') { $AU->{$au}{ts} = '---';}
    if(!defined($AU->{$au}{str}) || $AU->{$au}{str} eq '') {$AU->{$au}{str} = '---';}
    if(!defined($AU->{$au}{len})) {$AU->{$au}{len} = 0;}
    if(!defined($AU->{$au}{ins})) {$AU->{$au}{ins} = 0;}
    if(!defined($AU->{$au}{del})) {$AU->{$au}{del} = 0;}
    if(!defined($AU->{$au}{dur})) {$AU->{$au}{dur} = 0;}
    if(!defined($AU->{$au}{unit1}) || $AU->{$au}{unit1} eq '') {$AU->{$au}{unit1} = '---';}
    if(!defined($AU->{$au}{time1})) {$AU->{$au}{time1} = 0;}
    if(!defined($AU->{$au}{dur1})) {$AU->{$au}{dur1} = 0;}
    if(!defined($AU->{$au}{pause1})){$AU->{$au}{pause1} = 0;}
    if(!defined($AU->{$au}{dur2})) {$AU->{$au}{dur2} = 0;}
    if(!defined($AU->{$au}{time2})) {$AU->{$au}{time2} = 0;}
    if(!defined($AU->{$au}{pause2})) {$AU->{$au}{pause2} = 0;}
    if(!defined($AU->{$au}{unit2}) || $AU->{$au}{unit2} eq '') {$AU->{$au}{unit2} = '---';}

    printf FILE "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
      $n++,
      $AU->{$au}{ts},
      $AU->{$au}{ss},
      $SourceLang,
      $TargetLang,
      $Part,
      $Text,
      $Task,
      $SessionDuration,
      $DraftingStart,
      $DraftingEnd,
      $AU->{$au}{unit1},
      $AU->{$au}{time1},
      $AU->{$au}{dur1},
      $AU->{$au}{pause1},
      $AU->{$au}{par1},
      $AU->{$au}{unit2},
      $AU->{$au}{time2},
      $AU->{$au}{dur2},
      $AU->{$au}{pause2},
      $AU->{$au}{par2},
      $AU->{$au}{len},
      $AU->{$au}{ins},
      $AU->{$au}{del},
      $AU->{$au}{dur},
      $AU->{$au}{str};
#d($AU->{$au}{start});
  }
  close(FILE);
}

sub PrintTT {
  my ($fn) = @_;

  if(!defined( $TGT )) {
    printf STDERR "PrintTT: undefined TGT\n";
    return ;
  }

  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }

  printf FILE "TTid\tTToken\tSToken\tSL\tTL\tPerson\tText\tTask\tUnit1\tTime1\tDur1\tPause1\tParal1\tUnit2\tTime2\tDur2\tPause2\tParal2\tLen\tIns\tDel\tDur\tTyped\n";

  foreach my $tid (sort {$a <=> $b} keys %{$TGT}) {

#    if(!defined($TGT->{$tid}{'tok'})) { next;}

    if(!defined($TGT->{$tid}{tok}))    {$TGT->{$tid}{tok} = '---';}
    if(!defined($TGT->{$tid}{len}))    {$TGT->{$tid}{len} = 0;}
    if(!defined($TGT->{$tid}{ins}))    {$TGT->{$tid}{ins} = 0;}
    if(!defined($TGT->{$tid}{del}))    {$TGT->{$tid}{del} = 0;}
    if(!defined($TGT->{$tid}{dur}))    {$TGT->{$tid}{dur} = 0;}
    if(!defined($TGT->{$tid}{unit1}))  {$TGT->{$tid}{unit1} = '---';}
    if(!defined($TGT->{$tid}{unit2}))  {$TGT->{$tid}{unit2} = '---';}
    if(!defined($TGT->{$tid}{time1}))  {$TGT->{$tid}{time1} = 0;}
    if(!defined($TGT->{$tid}{time2}))  {$TGT->{$tid}{time2} = 0;}
    if(!defined($TGT->{$tid}{dur1}))   {$TGT->{$tid}{dur1} = 0;}
    if(!defined($TGT->{$tid}{dur2}))   {$TGT->{$tid}{dur2} = 0;}
    if(!defined($TGT->{$tid}{pause1})) {$TGT->{$tid}{pause1} = 0;}
    if(!defined($TGT->{$tid}{pause2})) {$TGT->{$tid}{pause2} = 0;}
    if(!defined($TGT->{$tid}{par1}))   {$TGT->{$tid}{par1} = 0;}
    if(!defined($TGT->{$tid}{par2}))   {$TGT->{$tid}{par2} = 0;}
    if(!defined($TGT->{$tid}{str}))    {$TGT->{$tid}{str} = "---";}

    my $sstr = '';
    if(defined($ALN) && defined($ALN->{tid}{$tid})) {
      foreach my $sid (sort {$a <=> $b} keys %{$ALN->{tid}{$tid}{id}}) {
        if($sstr ne '') {$sstr .= '_';}
        $sstr .= $SRC->{$sid}{tok};
      }
    }
    else {$sstr = '---';}


    printf FILE "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
      $tid,
      $TGT->{$tid}{tok},
      $sstr,
      $SourceLang,
      $TargetLang,
      $Part,
      $Text,
      $Task,
      $TGT->{$tid}{unit1},
      $TGT->{$tid}{time1},
      $TGT->{$tid}{dur1},
      $TGT->{$tid}{pause1},
      $TGT->{$tid}{par1},
      $TGT->{$tid}{unit2},
      $TGT->{$tid}{time2},
      $TGT->{$tid}{dur2},
      $TGT->{$tid}{pause2},
      $TGT->{$tid}{par2},
      $TGT->{$tid}{len},
      $TGT->{$tid}{ins},
      $TGT->{$tid}{del},
      $TGT->{$tid}{dur},
      $TGT->{$tid}{str};
  }
  close(FILE);
}


sub PrintST {
  my ($fn) = @_;

  if(!defined( $SRC )) {
    printf STDERR "PrintST: undefined SRC\n";
    return ;
  }

  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }

  printf FILE "STid\tSToken\tTToken\tSL\tTL\tPerson\tText\tTask\tUnit1\tTime1\tDur1\tPause1\tParal1\tUnit2\tTime2\tDur2\tPause2\tParal2\tLen\tIns\tDel\tDur\tTyped\n";

  foreach my $sid (sort {$a <=> $b} keys %{$SRC}) {

#    if(!defined($SRC->{$sid}{'tok'})) { next;}

    if(!defined($SRC->{$sid}{tok}))    {$SRC->{$sid}{tok} = '---';}
    if(!defined($SRC->{$sid}{ttok}))   {$SRC->{$sid}{ttok} = '---';}
    if(!defined($SRC->{$sid}{len}))    {$SRC->{$sid}{len} = 0;}
    if(!defined($SRC->{$sid}{ins}))    {$SRC->{$sid}{ins} = 0;}
    if(!defined($SRC->{$sid}{del}))    {$SRC->{$sid}{del} = 0;}
    if(!defined($SRC->{$sid}{dur}))    {$SRC->{$sid}{dur} = 0;}
    if(!defined($SRC->{$sid}{unit1}))  {$SRC->{$sid}{unit1} = '---';}
    if(!defined($SRC->{$sid}{unit2}))  {$SRC->{$sid}{unit2} = '---';}
    if(!defined($SRC->{$sid}{time1}))  {$SRC->{$sid}{time1} = 0;}
    if(!defined($SRC->{$sid}{time2}))  {$SRC->{$sid}{time2} = 0;}
    if(!defined($SRC->{$sid}{dur1}))   {$SRC->{$sid}{dur1} = 0;}
    if(!defined($SRC->{$sid}{dur2}))   {$SRC->{$sid}{dur2} = 0;}
    if(!defined($SRC->{$sid}{pause1})) {$SRC->{$sid}{pause1} = 0;}
    if(!defined($SRC->{$sid}{pause2})) {$SRC->{$sid}{pause2} = 0;}
    if(!defined($SRC->{$sid}{par1}))   {$SRC->{$sid}{par1} = 0;}
    if(!defined($SRC->{$sid}{par2}))   {$SRC->{$sid}{par2} = 0;}
    if(!defined($SRC->{$sid}{str}))    {$SRC->{$sid}{str} = "---";}

    printf FILE "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
      $sid,
      $SRC->{$sid}{tok},
      $SRC->{$sid}{ttok},
      $SourceLang,
      $TargetLang,
      $Part,
      $Text,
      $Task,
      $SRC->{$sid}{unit1},
      $SRC->{$sid}{time1},
      $SRC->{$sid}{dur1},
      $SRC->{$sid}{pause1},
      $SRC->{$sid}{par1},
      $SRC->{$sid}{unit2},
      $SRC->{$sid}{time2},
      $SRC->{$sid}{dur2},
      $SRC->{$sid}{pause2},
      $SRC->{$sid}{par2},
      $SRC->{$sid}{len},
      $SRC->{$sid}{ins},
      $SRC->{$sid}{del},
      $SRC->{$sid}{dur},
      $SRC->{$sid}{str};
  }
  close(FILE);
}

