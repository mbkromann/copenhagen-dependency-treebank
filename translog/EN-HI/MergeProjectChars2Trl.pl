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
  "Merge Translog and Project_N file: \n".
  "  -T in: Translog XML file <filename>\n".
  "  -P in: Project file\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_P $opt_T $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:P:v:h');

die $usage if defined($opt_h);

my $CHR = {};
my $TEXT = {};
my $TRANSLOG = {};
my $Verbose = 0;

if (defined($opt_v)) {$Verbose = $opt_v;}
if (!defined($opt_T)) {die $usage;}
if (!defined($opt_P)) {die $usage;}

ReadTranslog($opt_T);
ReadProject($opt_P);
SubstituteChars();
WriteTranslog();

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
  my $F = {};
  my ($lastTime, $t, $lastCursor, $c);

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  printf STDERR "ReadTranslog Reading: $fn\n";

  $type = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Events>/) {$type =1; }
    elsif(/<SourceTextChar>/) {$type =2; }
    elsif(/<TranslationChar>/) {$type =3; }
    elsif(/<FinalTextChar>/) {$type =4; }
    elsif(/<FinalText>/) {$type =5; }

## SourceText Positions
    if($type == 2 && /<CharPos/) {
      if(/Cursor="([0-9][0-9]*)"/){$cur =$1;}
      if(/Value="([^"]*)"/)       {$CHR->{Source}{$n}{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)     {$CHR->{Source}{$n}{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)     {$CHR->{Source}{$n}{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/) {$CHR->{Source}{$n}{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/){$CHR->{Source}{$n}{$cur}{'h'} = $1;}
    }
## TargetText Positions
    if($type == 3 && /<CharPos/) {
      if(/Cursor="([0-9][0-9]*)"/){$cur =$1;}
      if(/Value="([^"]*)"/)       {$CHR->{Target}{$n}{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)     {$CHR->{Target}{$n}{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)     {$CHR->{Target}{$n}{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/) {$CHR->{Target}{$n}{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/){$CHR->{Target}{$n}{$cur}{'h'} = $1;}
    }
## FinalText Positions
    elsif($type == 4 && /<CharPos/) {
      if(/Cursor="([0-9][0-9]*)"/) {$cur =$1;}
      if(/Value="([^"]*)"/)        {$CHR->{Final}{$n}{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)      {$CHR->{Final}{$n}{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)      {$CHR->{Final}{$n}{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/)  {$CHR->{Final}{$n}{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/) {$CHR->{Final}{$n}{$cur}{'h'} = $1;}
#if($CHR->{$cur}{'c'} eq "%"){print STDERR '%'. "\t$_";}
#else {printf STDERR "$CHR->{$cur}{'c'}\t$_";}
    } 
    elsif($type == 5) { $TEXT->{Final} .= $_;}
    $TRANSLOG->{$n++} = $_;

    if(/<\/Events>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/TranslationChar>/) {$type =0; }
    if(/<\/FinalTextChar>/) {$type =0; }
    if(/<\/FinalText>/) {$type =0; }
  }
  close(FILE);

  $TEXT->{Final} =~ s/^\s*<FinalText>//;
  $TEXT->{Final} =~ s/<\/FinalText>\s*$//;
  return $TRANSLOG;
}



##########################################################
# Read Translog Logfile
##########################################################

## SourceText Positions
sub ReadProject {
  my ($fn) = @_;
  my ($type, $time, $cur);

  my $n = 0;
  my ($lastTime, $t, $lastCursor, $c);

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  printf STDERR "ReadTranslog Reading: $fn\n";

  $type = 0;
  while(defined($_ = <FILE>)) {

    if(/<SourceUTF8>/) {$type =2; }
    if(/<TargetUTF8>/) {$type =3; }

    if($type == 2) { $TEXT->{Source} .= $_;}
    if($type == 3) { $TEXT->{Target} .= $_;}

    if(/<\/SourceUTF8>/ ) {$type =0; }
    if(/<\/TargetUTF8>/ ) {$type =0; }
  }
  close(FILE);

  $TEXT->{SS} = $TEXT->{Source};
  $TEXT->{TS} = $TEXT->{Target};
  if(defined($TEXT->{Source})) {$TEXT->{Source} =~ s/^\s*<SourceUTF8>//; }
  if(defined($TEXT->{Source})) {$TEXT->{Source} =~ s/<\/SourceUTF8>\s*$//; }
  if(defined($TEXT->{Target})) {$TEXT->{Target} =~ s/^\s*<TargetUTF8>//; }
  if(defined($TEXT->{Target})) {$TEXT->{Target} =~ s/<\/TargetUTF8>\s*$//; }
}


sub SubstituteChars {
  
  foreach my $lang (qw (Source Target Final)) {
    if(!defined($TEXT->{$lang})) {next;}

    my $T = [split(//, $TEXT->{$lang})];
    my $cur = 0;
    foreach my $n (sort {$a<=>$b} keys  %{$CHR->{$lang}}) {
      if(!defined($T->[$cur])) {
        printf STDERR "Undefined TEXT $cur\n";
      }
      elsif(!defined($CHR->{$lang}{$n}{$cur})) {
#        printf STDERR "Undefined CHR $lang $n $cur\n";
      }
      elsif($T->[$cur] ne $CHR->{$lang}{$n}{$cur}{'c'}) {
#       printf STDERR "unequal $lang %s\t%s\n", $T->[$cur], $CHR->{$lang}{$n}{$cur}{'c'};
        $TRANSLOG->{$n} =~ s/Value="[^"]*"/Value="$T->[$cur]"/;
      }
      else {
#      printf STDERR "OK $cur %s\t%s\n", $T->[$cur], $CHR->{$lang}{$n}{$cur}{'c'};
      }
      $cur++;
    }
    if($cur != $#{$T} + 1) {printf STDERR "$lang too many tokens $cur %s\n", $#{$T};}
  }
}

sub  WriteTranslog{

  foreach my $n (sort {$a<=>$b} keys  %{$TRANSLOG}) {
    print STDOUT "$TRANSLOG->{$n}";
    if($TRANSLOG->{$n} =~ /<\/TargetText>/) {
      if(defined($TEXT->{SS})) {print STDOUT "$TEXT->{SS}";}
      if(defined($TEXT->{TS})) {print STDOUT "$TEXT->{TS}";}
    }
  }
}
