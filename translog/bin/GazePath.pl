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
  "Gaze Path Similarity:\n".
  "  -T in:  Translog.Event.xml filename\n".
  "Options:\n".
  "  -s Print Simiparity Matrix\n".
  "  -p min production unit boundary [$MaxKeyGap]\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_O $opt_T $opt_s $opt_p $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:p:s:v:h');

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
my $Study = '';
my $Text = '';
my $Task = '';
my $Part = '';
my $PUboundary = 1000;
my $SessionDuration = 0;
my $DraftingStart = 0;
my $DraftingEnd = 0;

my $Verbose = 0;
        
if (defined($opt_v)) {$Verbose = $opt_v;}


### Read and Tokenize Translog log file
if (defined($opt_T)) {
  if(ReadTranslog($opt_T) == 0) {
    print STDERR "Trl2ProgGraphTables.pl WARNING: no process data in $opt_T\n";
    exit;
  }

	
  if(defined($opt_s)) {
    my $G = GazePathsSimilarity();
    my $sim = SimilarityMatrix($G);
    PrintSimMatrix($sim);
  }
  else {
    my $G = KeyGazePaths();
#    my $G = GazePaths();
  }
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
      if(/X="([^"]*)"/)          {$FIX->{$time}{'X'} = $1;}
      if(/Y="([^"]*)"/)          {$FIX->{$time}{'Y'} = $1;}
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
      if(/X="([^"]*)"/)          {$KEY->{$time}{'X'} = $1;}
      if(/Y="([^"]*)"/)          {$KEY->{$time}{'Y'} = $1;}
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


################################################################
# GazePath + Key
################################################################

sub GazePaths {
  my ($G);
  
  my $F;
  my $n=0;
  foreach my $f (sort  {$a <=> $b} keys %{$FIX}) {
    my @L = ();
	my  $x = 0;
    foreach my $g (sort  {$a <=> $b} keys %{$FIX}) {
      if($g < $f) {next;}
	  if($g > $f+5000) {last;}
	  push(@L, $FIX->{$g});
	  $x=$g;
	  if(scalar(@L) >= 10) {last;}
	}
	
    my $sub = 0;
	my $cur = 0;
	my $dur = 0;
	my $y = 0;
	my $stroke = 0;
	my $k1 = 0;
	
	### Key --- Fix
	foreach my $k (sort  {$a <=> $b} keys %{$KEY}) {
	  if(($k - $k1) < $PUboundary) {$stroke ++}
	  else {$stroke = 0;}
	  $k1=$k;
	  
	  if($k < $x) {next;}	  
	  $sub = sqrt((($KEY->{$k}{X} - $FIX->{$x}{X}) ** 2) + ((($KEY->{$k}{Y} - $FIX->{$x}{Y}) ** 2)*2));	  
	  $cur = $KEY->{$k}{cur} - $FIX->{$x}{cur};
	  $y=$k;
	  last;
	}
	$F->{dist_k} = int($sub);
	$F->{cur_k} = $cur;
	$F->{stroke} = $stroke;
	$F->{time} = $y - $x;
	if($y > 0) {
#	d($KEY->{$y});
	  if($KEY->{$y}{type} eq 'ins') {$F->{type} = 1;}
	  elsif($KEY->{$y}{type} eq 'del') {$F->{type} = 2;}
	  else {$F->{type} = 3;}
    }
    else {$F->{type} = 0;} 
	
	### Fix --- Fux
	my $sid = 0;
	for (my $i = 1; $i < 10; $i++) {
      $dur= $cur = $sub = 0;
	  if($i < scalar(@L)) {
	    $sub = sqrt((($L[$i]{X} - $L[$i-1]{X}) ** 2) + ((($L[$i]{Y} - $L[$i-1]{Y}) ** 2)*2));
		$cur = $L[$i]{cur} - $L[$i-1]{cur};
		$dur = $L[$i-1]{dur};
#		$sid = (split(/\+/, $L[$i]{sid}))[0] - (split(/\+/, $L[$i-1]{sid}))[0]; 
		$sid = (split(/\+/, $KEY->{$y}{sid}))[0] - (split(/\+/, $L[$i-1]{sid}))[0]; 
#		print STDERR "xxx $sid\n";
      }
	  $F->{"dist_$i"} = int($sub);
	  $F->{"cur_$i"} = $cur;
	  $F->{"dur_$i"} = $dur;
	  $F->{"sid_$i"} = $sid;
    }
	
	## PRINT OUT
	if($n == 0) {
      $cur = 0;
	  foreach my $k (sort keys %{$F}) { 
	    if($cur >0) {print STDOUT ",";} 
	    print STDOUT "$k";
	    $cur++;
      }
      print STDOUT "\n";
	}

    $cur = 0;
	foreach my $k (sort keys %{$F}) { 
	  if($cur >0) {print STDOUT ",";} 
	  print STDOUT "$F->{$k}";
	  $cur++;
    }
    print STDOUT "\n";
    $n++;
#	$G->{$f}{FIX} = \@L;
#    $G->{$f}{KEY} = $KEY->{$k};
  }
  return $F;
}


################################################################
# Key + GazePath 
################################################################

sub KeyGazePaths {
  my ($G);
  
  my $F;
  my $n=0;
  foreach my $k (sort  {$a <=> $b} keys %{$KEY}) {

    if($KEY->{$k}{type} eq 'ins') {$F->{type} = 1;}
	elsif($KEY->{$k}{type} eq 'del') {$F->{type} = 2;}
	else {$F->{type} = 3;}

	my $stroke = 0;
	my $b1 = 0;
	foreach my $b (sort  {$a <=> $b} keys %{$KEY}) {
	  if(($b - $b1) < $PUboundary) {$stroke ++}
	  else {$stroke = 0;}
	  $b1=$b; 
	  if($b > $k) {last;}	  	  
	}
	$F->{stroke} = $stroke;
	
    my @L = ();
	my  $x = 0;
    foreach my $f (sort  {$b <=> $a} keys %{$FIX}) {
      if($f > $k) {next;}
	  if($f < $k-5000) {last;}	  
	  if($x >= 10) {last;}

      $F->{"dist_$x"} = int(sqrt((($KEY->{$k}{X} - $FIX->{$f}{X}) ** 2) + ((($KEY->{$k}{Y} - $FIX->{$f}{Y}) ** 2)*2)));	  
      $F->{"dur_$x"} = $FIX->{$f}{dur};
      $F->{"tme_$x"} = $k - $f;
#      $F->{"sid_$x"} = (split(/\+/, $KEY->{$k}{sid}))[0] - (split(/\+/, $FIX->{$f}{sid}))[0]; 
#      $F->{"cur_$x"} = $KEY->{$k}{cur} - $FIX->{$f}{cur};
	  $x++;
    }
	while($x < 10) {
      $F->{"dist_$x"} = 0; 
      $F->{"dur_$x"} = 0;
      $F->{"tme_$x"} = 0;
#      $F->{"cur_$x"} = 0;
#      $F->{"sid_$x"} = 0;
	  $x++;
    }
	
# Print
    my 
	$cur; 	
	if($n == 0) {
      $cur = 0;
	  foreach my $k (sort keys %{$F}) { 
	    if($cur >0) {print STDOUT ",";} 
	    print STDOUT "$k";
	    $cur++;
      }
      print STDOUT "\n";
	}

    $cur = 0;
	foreach my $k (sort keys %{$F}) { 
	  if($cur >0) {print STDOUT ",";} 
	  print STDOUT "$F->{$k}";
	  $cur++;
    }
    print STDOUT "\n";
    $n++;
  }
  return $F;
}


################################################################
# Gaze Path Similarity
################################################################

sub GazePathsSimilarity {
  my ($G);
  
  foreach my $k (sort  {$a <=> $b} keys %{$KEY}) {
    my $s = '';
	if($KEY->{$k}{'sid'} ne '-1' ) {
	  my @L = ();
      foreach my $f (sort  {$b <=> $a} keys %{$FIX}) {
	    if($f < $k-5000) {last;}
	    if($f <= $k) {
          push(@L, $FIX->{$f});
		}
	  }
	  $G->{$k}{FIX} = \@L;
      $G->{$k}{KEY} = $KEY->{$k};
    }
  }
  return $G;
}

sub SimilarityMatrix {
  my ($G) = @_;
  my @sim = ();

  my $i= 0;  
  foreach my $k (keys %{$G}) {
    my $j = 0;
    foreach my $g (keys %{$G}) {
      $sim[$i][$j++] = EditDistance($G->{$k}, $G->{$g});
	} 
#printf STDERR "SimilarityMatrix: $i\n";
#d($sim[$i]);
	$i++;
  }
  return \@sim;
}


sub EditDistance {
  my ($P1, $P2) = @_;
   
  my $p1 = scalar(@{$P1->{FIX}});
  my $p2 = scalar(@{$P2->{FIX}});
 
  my $K1 = $P1->{KEY};
  my $K2 = $P2->{KEY};

  my @dist = ();
  $dist[0][0] = 0;
  for (my $i = 1; $i < $p1; $i++) { 
    $P1->{FIX}[$i]{KX} = $P1->{FIX}[$i]{X} - $P1->{KEY}{X};
    $P1->{FIX}[$i]{KY} = $P1->{FIX}[$i]{Y} - $P1->{KEY}{Y};
    $dist[$i][0] = $dist[$i-1][0] + $P1->{FIX}[$i]{dur}; 
  }
  for (my $j = 1; $j < $p2; $j++) { 
    $P2->{FIX}[$j]{KX} = $P2->{FIX}[$j]{X} - $P2->{KEY}{X};
    $P2->{FIX}[$j]{KY} = $P2->{FIX}[$j]{Y} - $P2->{KEY}{Y};
    $dist[0][$j] = $dist[0][$j-1] + $P2->{FIX}[$j]->{dur}; 
  }

  for (my $j = 1; $j < $p2; $j++) {
    for (my $i = 1; $i < $p1; $i++) {
	  my $ins = $P1->{FIX}[$i]{dur} + $dist[$i-1][$j];
	  my $del = $P2->{FIX}[$j]{dur} + $dist[$i][$j-1];
	  my $sub = FixSimilarity($P1->{FIX}[$i], $P2->{FIX}[$j]) + $dist[$i-1][$j-1];
	  $dist[$i][$j] = min($sub, $ins, $del);
#	  print STDERR "EditDistance3: $i, $j, $dist[$i][$j]\n";
    }
  }
#  print "levenshtein distance = $dist[$p1-1][$p2-1]\n";
  return int($dist[$p1-1][$p2-1]);
}

## returns $max_dur - $min_dur ... $max_dur + $min_dur
sub FixSimilarity {
  my ($P1, $P2) = @_;
  my ($max, $min, $x);

  my $dist = 0;
  if(defined($P1->{KX})) {
    $dist = sqrt((($P1->{KX} - $P2->{KX}) ** 2) + ((($P1->{KY} - $P2->{KY}) ** 2)*2));
  }
  else {
    $dist = sqrt((($P1->{X} - $P2->{X}) ** 2) + ((($P1->{Y} - $P2->{Y}) ** 2)*2));
  }
  $max=$min=0;
  if($P1->{dur}>$P2->{dur}) {$max=$P1->{dur};$min=$P2->{dur}}
  else {$max=$P2->{dur};$min=$P1->{dur}}

  if($dist < 60) {$x = -1}
  elsif($dist < 180) { $x=($dist-60)/120 -1;}
  else { $x=1;}
  
#  d($P1);
#  d($P2);
#  printf STDERR "FixSimilarity2: $dist $max, $min $x %s\n", $max + ($min*$x); 

  return $max + ($min*$x);
}


sub PrintSimMatrix {
  my ($sim) = @_;

  print STDOUT "Name,";
  for (my $j = 1; $j < scalar(@{$sim->[0]}); $j++) {
    if($j > 1) { print STDOUT ",";}
	print STDOUT "Path_$j";
  }
  print STDOUT "\n";
  for (my $i = 1; $i < scalar(@{$sim}); $i++) { 
    print STDOUT "Path_$i,";
    for (my $j = 1; $j < scalar(@{$sim->[$i]}); $j++) { 
      if($j > 1) { print STDOUT ",";}
      print STDOUT "$sim->[$i][$j]"; 
	}
	print STDOUT "\n";
  }
}

sub min(@) {
    my $minval = shift;
    my $i;
    while ($i = shift) {
	$minval = $i if ($i < $minval);
    }
    return $minval;
}

    