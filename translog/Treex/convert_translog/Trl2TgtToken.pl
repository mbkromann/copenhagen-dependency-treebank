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
  "Extract Tgt token tables from Translog file: \n".
  "  -T in:  Translog XML file <filename>\n".
  "  -O out: Write output   <filename>.{kd,fd,fu,pu,st}\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_O $opt_T $opt_v $opt_h);

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
if (defined($opt_T) && defined($opt_O)) {
  ReadTranslog($opt_T);
  TTProduction();
  Parallel();
  PrintTT("$opt_O");
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
  my ($type, $time, $id);

  my $n = 0;

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");

  $type = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Language/) {
      if(/source="([^"])"/) {$SourceLang = $1; }
      if(/target="([^"])"/) {$TargetLang = $1; }
    }
    elsif(/<Fixations>/)    {$type = 2; }
    elsif(/<Modifications>/){$type = 3; }
    elsif(/<ProdUnits>/)    {$type = 4; }
    elsif(/<FixUnits>/)     {$type = 5; }
    elsif(/<FinalToken>/)   {$type = 6; }
    elsif(/<SourceToken>/)  {$type = 7; }
    elsif(/<Alignment>/)    {$type = 8; }
	
    if($type == 7 && /<Token/) {
      if(/ id="([0-9][0-9]*)"/) {$id =$1;}
      if(/tok="([^"]*)"/)   {$SRC->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$SRC->{$id}{space} = Rescape(MSunescape($1));}
      if(/ cur="([^"]*)"/)    {$SRC->{$id}{cur} = $1;}
    }
    if($type == 6 && /<Token/) {
      if(/ id="([0-9][0-9]*)"/) {$id =$1;}
      if(/tok="([^"]*)"/)   {$TGT->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$TGT->{$id}{space} = Rescape(MSunescape($1));}
      if(/cur="([^"]*)"/)    {$TGT->{$id}{cur} = $1;}
    }
    if($type == 8 && /<Align/) {
      if(/SourceId="([^"]*)"/) {$id =$1;}
      if(/FinalId="([^"]*)"/)   {$ALN->{$1}{$id}++;}
    }
    elsif($type == 2 && /<Fix /) {
#printf STDERR "Translog: %s",  $_;
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/win="([^"]*)"/)        {$FIX->{$time}{'win'} = $1;}
      if(/dur="([0-9][0-9]*)"/)  {$FIX->{$time}{'dur'} = $1;}
      if(/cur="([-0-9][0-9]*)"/) {$FIX->{$time}{'cur'} = $1;}
      if(/ id="([^"]*)"/)         {$FIX->{$time}{'id'} = $1;}
      if(/sid="([^"]*)"/)        {$FIX->{$time}{'sid'} = $1;}
      if($FIX->{$time}{'sid'} eq '') {$FIX->{$time}{'sid'} = -1;}

    }
    elsif($type == 3 && /<Mod /) {
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/cur="([0-9][0-9]*)"/)  {$KEY->{$time}{'cur'} = $1;}
      if(/chr="([^"]*)"/)        {$KEY->{$time}{'char'} = Rescape(Rescape(MSunescape($1)));}
      if(/type="([^"]*)"/)       {$KEY->{$time}{'type'} = $1;}
      if(/ id="([^"]*)"/)        {$KEY->{$time}{'tid'} = $1;}
      if(/sid="([^"]*)"/)        {$KEY->{$time}{'sid'} = $1;}
      if($KEY->{$time}{'sid'} eq '') {$KEY->{$time}{'sid'} = -1;}
    }
#    <PU start="10685" dur="7049" pause="2719" parallel="69.1587" ins="34" del="0" src="3+4" tgt="1+3+4" str="Mordersygeplejerske&nbsp;modtager&nbsp;fire&nbsp;" />

    #ProdUnits
    elsif($type == 4 && /<PU /) {
      if(/start="([0-9][0-9]*)"/) {$time =$1;}
      if(/dur="([0-9][0-9]*)"/)   {$PU->{$time}{'dur'} = $1;}
      if(/pause="([0-9][0-9]*)"/) {$PU->{$time}{'pause'} = $1;}
      if(/parallel="([^"]*)"/)    {$PU->{$time}{'par'} = $1;}
      if(/ins="([-0-9][0-9]*)"/)  {$PU->{$time}{'ins'} = $1;}
      if(/del="([-0-9][0-9]*)"/)  {$PU->{$time}{'del'} = $1;}
      if(/src="([^"]*)"/)         {$PU->{$time}{'sid'} = $1;}
      if(/tgt="([^"]*)"/)         {$PU->{$time}{'tid'} = $1;}
      if(/str="([^"]*)"/)         {$PU->{$time}{'str'} = Rescape(Rescape(MSunescape($1)));}
      if($PU->{$time}{'sid'} eq '') {$PU->{$time}{'sid'} = -1;}
      if($PU->{$time}{'tid'} eq '') {$PU->{$time}{'tid'} = -1;}
      if($PU->{$time}{'str'} eq '') {$PU->{$time}{'str'} = '_';}
    }
# <FU start="272970" win="2" dur="3429" pause="0" parallel="100.0000" id="1+150" src="" />
  
    #FixUnits
    elsif($type == 5 && /<FU /) {
      if(/start="([0-9][0-9]*)"/) {$time =$1;}
      if(/win="([^"]*)"/)         {$FU->{$time}{'win'} = $1;}
      if(/dur="([0-9][0-9]*)"/)   {$FU->{$time}{'dur'} = $1;}
      if(/pause="([0-9][0-9]*)"/) {$FU->{$time}{'pause'} = $1;}
      if(/parallel="([^"]*)"/)   {$FU->{$time}{'par'} = $1;}
      if(/id="([-0-9][0-9]*)"/)   {$FU->{$time}{'id'} = $1;}
      else {$FU->{$time}{'id'} = -1;}
      if(/src="([^"]*)"/)         {$FU->{$time}{'sid'} = $1;}
      if($FU->{$time}{'sid'} eq '') {$FU->{$time}{'sid'} = -1;}
    }

    if(/<\/SourceToken>/)  {$type = 0; }
    if(/<\/Fixations>/)    {$type = 0; }
    if(/<\/Modifications>/){$type = 0; }
    if(/<\/ProdUnits>/)    {$type = 0; }
    if(/<\/FixUnits>/)     {$type = 0; }
  }
  close(FILE);
}

#################################################

sub TTProduction {

  my ($ins, $del, $len, $start, $end, $last, $id) = 0;
  $ins=$del=$len=$start=$end=$last=$id = 0;
  my $str = '';
  my $type = 'ins';

  foreach my $t (sort  {$a <=> $b} keys %{$KEY}) {
#printf STDERR "AAAAA\n";
#d($KEY->{$t});

    if($start > 0 && $KEY->{$t}{tid} != $id) {
      if(!defined($TGT->{$id}{prod})) {
        $TGT->{$id}{prod} += $end - $start;
        $TGT->{$id}{prod2} = 0;
      }
      else {$TGT->{$id}{prod2} += $end - $start;}
      push(@{$TGT->{$id}{start}}, $start);
      push(@{$TGT->{$id}{end}}, $end);
      push(@{$TGT->{$id}{last}}, $last);
      if($type eq 'del') {$str .= ']';}

      $TGT->{$id}{ins} += $ins;
      $TGT->{$id}{del} += $del;
      $TGT->{$id}{len} += $len;
      $TGT->{$id}{str} .= $str;
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

################################################################
## Print table with (wnr, token) 

sub PrintTT {
  my ($fn) = @_;
  my ($f, $s);

#source file (.src)
  if(!defined( $TGT )) {
    printf STDERR "PrintTT: undefined SOURCE\n";
    return ;
  }
#  if(!open(FILE, ">:encoding(utf8)", $fn)) {
#    printf STDERR "cannot open: $fn\n";
#    return ;
#  }

  printf STDOUT "id\tTrans\tSL\TL\ttoken\tStoken\ttyped\tlen\tins\tdel\time1\ttime2\n";
  foreach $f (sort {$a <=> $b} keys %{$TGT}) {
#print STDERR "TTTT\n";
#d($TGT->{$f});

    if(!defined($TGT->{$f}{'tok'})) { next;}

    my $sstr = '';
    if(defined($ALN) && defined($ALN->{$f})) { 
      foreach my $sid (sort {$a <=> $b} keys %{$ALN->{$f}}) {
        if($sstr ne '') {$sstr .= '_';}
        $sstr .= $SRC->{$sid}{tok};
      }
    }
    else {$sstr = '---';}

    printf STDOUT "%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
      $f, 
      $SourceLang,
      $TargetLang,
      $TGT->{$f}{'tok'},
      $TGT->{$f}{'tok'},
      $sstr,
      $TGT->{$f}{'str'},
      $TGT->{$f}{'len'},
      $TGT->{$f}{'ins'}, 
      $TGT->{$f}{'del'},
      $TGT->{$f}{'prod'}, 
      $TGT->{$f}{'prod2'};
      
  }
#  close (FILE);
}


