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
  "Print Key and Mod tables from Translog .Event.xml files STDOUT for manual fixation correction\n".
  "  -T in:  Translog XML file <filename>\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_T $opt_p $opt_v $opt_h);

use Getopt::Std;
getopts ('T:v:h');

die $usage if defined($opt_h);

my $SRC = undef;
my $TGT = undef;
my $EVENT = undef;
my $Verbose = 0;
        
if (defined($opt_v)) {$Verbose = $opt_v;}


### Read and Tokenize Translog log file
if (defined($opt_T)) {
  ReadTranslog($opt_T);
  PrintKeyMod();
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
#  $in =~ s/([^a-zA-Z0-9 '"_.;:|!@#$%^&*()+=\\|}{\[\]-])/./g;
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

    if(/<SourceToken/)     {$type = 1; }
    elsif(/<FinalToken/)   {$type = 2; }
    elsif(/<Fixations/)    {$type = 3; }
    elsif(/<Modifications/){$type = 4; }
	
    if($type == 1 && /<Token/) {
      if(/id="([0-9][0-9]*)"/) {$id =$1;}
      if(/cur="([^"]*)"/)    {$SRC->{$id}{id} = $1;}
      if(/tok="([^"]*)"/)   {$SRC->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$SRC->{$id}{space} = Rescape(MSunescape($1));}
    }
    if($type == 2 && /<Token/) {
      if(/id="([0-9][0-9]*)"/) {$id =$1;}
      if(/tok="([^"]*)"/)   {$TGT->{$id}{tok} = Rescape(MSunescape($1));}
      if(/space="([^"]*)"/) {$TGT->{$id}{space} = Rescape(MSunescape($1));}
      if(/cur="([^"]*)"/)   {$TGT->{$id}{id} = $1;}
    }
    elsif($type == 3 && /<Fix /) {
#printf STDERR "Translog: %s",  $_;
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/win="([^"]*)"/)        {$EVENT->{$time}{fix}{'win'} = $1;}
      if(/dur="([0-9][0-9]*)"/)  {$EVENT->{$time}{fix}{'dur'} = $1;}
      if(/cur="([-0-9][0-9]*)"/) {$EVENT->{$time}{fix}{'cur'} = $1;}
      if(/tid="([^"]*)"/)        {$EVENT->{$time}{fix}{'tid'} = $1;}
      if(/sid="([^"]*)"/)        {$EVENT->{$time}{fix}{'sid'} = $1;}
      if($EVENT->{$time}{fix}{'sid'} eq '') {$EVENT->{$time}{fix}{'sid'} = -1;}
      if($EVENT->{$time}{fix}{'tid'} eq '') {$EVENT->{$time}{fix}{'tid'} = -1;}

    }
    elsif($type == 4 && /<Mod /) {
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/cur="([0-9][0-9]*)"/)  {$EVENT->{$time}{key}{'cur'} = $1;}
      if(/chr="([^"]*)"/)        {$EVENT->{$time}{key}{'char'} = Rescape(Rescape(MSunescape($1)));}
      if(/type="([^"]*)"/)       {$EVENT->{$time}{key}{'type'} = $1;}
      if(/tid="([^"]*)"/)        {$EVENT->{$time}{key}{'tid'} = $1;}
      if(/sid="([^"]*)"/)        {$EVENT->{$time}{key}{'sid'} = $1;}
      if($EVENT->{$time}{key}{'sid'} eq '') {$EVENT->{$time}{key}{'sid'} = -1;}
      if($EVENT->{$time}{key}{'tid'} eq '') {$EVENT->{$time}{key}{'tid'} = -1;}
    }
#    <PU start="10685" dur="7049" pause="2719" parallel="69.1587" ins="34" del="0" src="3+4" tgt="1+3+4" str="Mordersygeplejerske&nbsp;modtager&nbsp;fire&nbsp;" />

    if(/<\/SourceToken>/)  {$type = 0; }
    if(/<\/FinalToken>/)  {$type = 0; }
    if(/<\/Fixations>/)    {$type = 0; }
    if(/<\/Modifications>/){$type = 0; }
  }
  close(FILE);
}

sub PrintKeyMod {
  my ($fn) = @_;

  if(!defined( $EVENT )) {
    printf STDERR "PrintFD: undefined Keyboard data \n";
    return ;
  }

  printf STDOUT "n\ttime\ttype\tcur\twin\tid\tstr\twin_c\tid_c\tstr_c\n";

  my $n = 0;
  foreach my $t (sort  {$a <=> $b} keys %{$EVENT}) {
    if($EVENT->{$t}{key}) {
      my $type  = 'key';
      if($EVENT->{$t}{key}{type} eq "ins") {$type = "key_ins"}
      if($EVENT->{$t}{key}{type} eq "del") {$type = "key_del"}
      print STDOUT "$n\t$t\t$type\t$EVENT->{$t}{key}{'cur'}\t2\t$EVENT->{$t}{key}{'tid'}\t$EVENT->{$t}{key}{char}\tt2\t$EVENT->{$t}{key}{'tid'}\t$EVENT->{$t}{key}{char}\n";
      $n++;
    }
    if($EVENT->{$t}{fix}) {
      my $str = '';
      my $id  = -1;
      if($EVENT->{$t}{fix}{win} == 1) {$id = $EVENT->{$t}{fix}{sid}; $str=$SRC->{$id}{tok}}
      elsif($EVENT->{$t}{fix}{win} == 2) {$id = $EVENT->{$t}{fix}{tid}; $str=$TGT->{$id}{tok}}
#d($TGT);
      print STDOUT "$n\t$t\tfix\t$EVENT->{$t}{fix}{'cur'}\t$EVENT->{$t}{fix}{'win'}\t$id\t$str\t$EVENT->{$t}{fix}{'win'}\t$id\t$str\n";
      $n++;
    }

  }
  close (FILE);
}

