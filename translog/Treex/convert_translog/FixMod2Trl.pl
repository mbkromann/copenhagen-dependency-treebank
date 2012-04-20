#!/usr/bin/perl -w

use strict;
use warnings;

use Encode qw(encode decode);

# Escape characters 
my $map = { map { $_ => 1 } split( //o, "\\<> \t\n\r\f\"" ) };

use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

my $usage =
  "Translog (incl src, tgt, atag) file to Treex: \n".
  "  -T in:  Translog XML file <filename>.xml\n".
  "     out: Write treex file to <filename>.treex.gz\n".
  "Options:\n".
  "  -O <filename>: Write output <filename>.treex.gz\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_O $opt_T $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:v:t:h');


my $ALN = undef;
my $FIX = undef;
my $EYE = undef;
my $KEY = undef;
my $CHR = undef;
my $TOK = undef;
my $TEXT = undef;
my $TRANSLOG = {};
my $Verbose = 0;

## Key mapping
my $lastKeyTime = 0;
my $lastCursorPos = 0;
my $TextLength = 0;
my $fn = '';

die $usage if defined($opt_h);
die $usage if not defined($opt_T);

if(defined($opt_O)) { $fn = $opt_O;}
else {$fn = $opt_T; $fn =~ s/.xml$/_tab.xml/;}

  my $KeyLog = ReadTranslog($opt_T);
  KeyLogAnalyse($KeyLog);

  CheckForward();
  MapTok2Chr();
  MapSource();
  MapTarget();
  CheckBackward ();

  FixModTable();
  PrintTranslog($fn);
exit;

############################################################
# escape
############################################################

#sub escape {
#  my ($in) = @_;
##printf STDERR "in: $in\n";
#  $in =~ s/(.)/exists($map->{$1})?sprintf('\\%04x',ord($1)):$1/egos;
#  return $in;
#}
#
#sub unescape {
#  my ($in) = @_;
#  $in =~ s/\\([0-9a-f]{4})/sprintf('%c',hex($1))/egos;
#  return $in;
#}


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



##########################################################
# Read Translog Logfile
##########################################################

## SourceText Positions
sub ReadTranslog {
  my ($fn) = @_;
  my ($type, $time, $cur);

  my $KeyLog = {};
  my $key = 0;
  my $F = '';
  my ($lastTime, $t, $lastCursor, $c);

  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  if($Verbose) {printf STDERR "ReadTranslog Reading: $fn\n";}

  $type = 0;
  my $n = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;
    $TRANSLOG->{$n++} = $_;

    if(/<Events>/) {$type =1; }
    elsif(/<SourceTextChar>/) {$type =2; }
    elsif(/<TranslationChar>/) {$type =3; }
    elsif(/<FinalTextChar>/) {$type =4; }
    elsif(/<FinalText>/)   {$type =5; }
    elsif(/<Alignment>/)   {$type =6; }
    elsif(/<SourceToken>/){$type =7; }
    elsif(/<FinalToken>/) {$type =8; }
	

## SourceText Positions
    if($type == 2 && /<CharPos/) {
      if(/Cursor="([0-9][0-9]*)"/){$cur =$1;}
      if(/Value="([^"]*)"/)       {$CHR->{src}{$cur}{'c'} = MSunescape($1);}
      if(/X="([-0-9][0-9]*)"/)     {$CHR->{src}{$cur}{'x'} = $1;}
      if(/Y="([-0-9][0-9]*)"/)     {$CHR->{src}{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/) {$CHR->{src}{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/){$CHR->{src}{$cur}{'h'} = $1;}
    }
## TranslationChar Positions
    elsif($type == 3 && /<CharPos/) {
      if(/Cursor="([0-9][0-9]*)"/) {$cur =$1;}
      if(/Value="([^"]*)"/)        {$TEXT->{$cur}{'c'} = $CHR->{tra}{$cur}{'c'} = MSunescape($1);}
      if(/X="([-0-9][0-9]*)"/)      {$CHR->{tra}{$cur}{'x'} = $1;}
      if(/Y="([-0-9][0-9]*)"/)      {$CHR->{tra}{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/)  {$CHR->{tra}{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/) {$CHR->{tra}{$cur}{'h'} = $1;}
      $TextLength++;
    }
## FinalText Positions
    elsif($type == 4 && /<CharPos/) {
#print STDERR "Final: $_";
      if(/Cursor="([0-9][0-9]*)"/) {$cur =$1;}
      if(/Value="([^"]*)"/)        {$CHR->{fin}{$cur}{'c'} = MSunescape($1);}
      if(/X="([-0-9][0-9]*)"/)      {$CHR->{fin}{$cur}{'x'} = $1;}
      if(/Y="([-0-9][0-9]*)"/)      {$CHR->{fin}{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/)  {$CHR->{fin}{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/) {$CHR->{fin}{$cur}{'h'} = $1;}
#if($CHR->{fin}{$cur}{'c'} eq "%"){print STDERR '%'. "\t$_";}
#else {printf STDERR "$CHR->{fin}{$cur}{'c'}\t$_";}
    } 
## Mouse has no impact on insertion/deletion$CHR->{src}{$f}{'end'}
    elsif($type == 1 && /<Mouse/) { }
    elsif($type == 1 && /<Eye/) {
      if(/Time="([0-9][0-9]*)"/)  {$time =$1;}
      if(/TT="([0-9][0-9]*)"/)    {$EYE->{$time}{'tt'} = $1;}
      if(/Win="([0-9][0-9]*)"/)   {$EYE->{$time}{'w'} = $1;}
      else{$EYE->{$time}{'w'} = 0;}
      if(/Xl="([-0-9][0-9]*)"/)    {$EYE->{$time}{'xl'} = $1;}
      else{$EYE->{$time}{'xl'} = 0;}
      if(/Yl="([-0-9][0-9]*)"/)    {$EYE->{$time}{'yl'} = $1;}
      else{$EYE->{$time}{'yl'} = 0;}
      if(/pl="([0-9.][0-9.]*)"/)  {$EYE->{$time}{'pl'} = $1;}
      else{$EYE->{$time}{'pl'} = 0;}
      if(/Xr="([-0-9][0-9]*)"/)    {$EYE->{$time}{'xr'} = $1;}
      else{$EYE->{$time}{'xr'} = 0;}
      if(/Yr="([-0-9][0-9]*)"/)    {$EYE->{$time}{'yr'} = $1;}
      else{$EYE->{$time}{'yr'} = 0;}
      if(/pr="([0-9.][0-9.]*)"/)  {$EYE->{$time}{'pr'} = $1;}
      else{$EYE->{$time}{'pr'} = 0;}
      if(/Cursor="([0-9][0-9]*)"/){$EYE->{$time}{'c'} = $1;}
      else{$EYE->{$time}{'c'} = 0;}
      if(/Xc="([-0-9][0-9]*)"/)    {$EYE->{$time}{'xc'} = $1;}
      else{$EYE->{$time}{'xc'} = 0;}
      if(/Yc="([-0-9][0-9]*)"/)    {$EYE->{$time}{'yc'} = $1;}
      else{$EYE->{$time}{'yc'} = 0;}
    }

    elsif($type == 1 && /<Fix/) {
# Skip End-of-Fixation
      if(!/Block="([0-9][0-9]*)"/) {next;}
      elsif($1 == 0) {next;}

      if(/Time="([0-9][0-9]*)"/)  {$time =$1;}
      if(/Cursor="([0-9][0-9]*)"/){$FIX->{$time}{'c'} = $1;}
      else {$FIX->{$time}{'c'} = 0;}
      if(/Block="([0-9][0-9]*)"/) {$FIX->{$time}{'b'} = $1;}
      else {$FIX->{$time}{'b'} = 0;}
      if(/Win="([0-9][0-9]*)"/)   {$FIX->{$time}{'w'} = $1;}
      else {$FIX->{$time}{'w'} = 0;}
      if(/Dur="([0-9][0-9]*)"/)   {$FIX->{$time}{'d'} = $1;}
      else {$FIX->{$time}{'d'} = 0;}
      if(/X="([-0-9][0-9]*)"/)     {$FIX->{$time}{'x'} = $1;}
      else {$FIX->{$time}{'x'} = 0;}
      if(/Y="([-0-9][0-9]*)"/)     {$FIX->{$time}{'y'} = $1;}
      else {$FIX->{$time}{'y'} = 0;}

    }
    elsif($type == 1 && /<Key/) {  $KeyLog->{$key++} = $_; }
    elsif($type == 5) {  $F .= $_; }
    elsif($type == 6 && /<Align /) {
#print STDERR "ALIGN: $_";
      my ($si, $ti, $ss, $ts);
      if(/SourceId="([^\"]*)"/) {$si =$1;}
      if(/Source="([^\"]*)"/)    {$ss =$1;}
      if(/FinalId="([^\"]*)"/)  {$ti =$1;}
      if(/Final="([^\"]*)"/)     {$ts =$1;}
      $ALN->{'tid'}{$ti}{'sid'}{$si} = $ss;
    }
    elsif($type == 7 && /<Token/) {
      if(/cur="([0-9][0-9]*)"/) {$cur =$1;}
      if(/tok="([^"]*)"/)   {$TOK->{src}{$cur}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$TOK->{src}{$cur}{space} = MSunescape($1);}
      if(/id="([^"]*)"/)    {$TOK->{src}{$cur}{id} = $1;}
    }

    elsif($type == 8 && /<Token/) {
      if(/cur="([0-9][0-9]*)"/) {$cur =$1;}
      if(/tok="([^"]*)"/)   {$TOK->{fin}{$cur}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$TOK->{fin}{$cur}{space} = MSunescape($1);}
      if(/id="([^"]*)"/)    {$TOK->{fin}{$cur}{id} = $1;}
    }

    if(/<\/FinalText>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/Events>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/TranslationChar>/) {$type =0; }
    if(/<\/FinalTextChar>/) {$type =0; }
    if(/<\/FinalText>/) {$type =0; }
    if(/<\/Alignment>/) {$type =0; }
    if(/<\/SourceToken>/){$type =0; }
    if(/<\/FinalToken>/) {$type =0; }
  }
  close(FILE);

#foreach my $f (sort {$a <=> $b} keys %{$TEXT}) { print STDERR "$TEXT->{$f}{c}" }
#printf STDERR "\n";

  return $KeyLog;
}

##########################################################
# Parse Keystroke Log
##########################################################

## map all keystrokes on ins and del
sub KeyLogAnalyse {
  my ($K) = @_;

  foreach my $f (sort {$a <=> $b} keys %{$K}) {
    $_ = $K->{$f};

    if(!/Type="insert"/ && !/Type="delete"/  && !/Type="edit"/ && !/Type="return"/ ) { 
      if(/Type="navi"/ && /Cursor="([0-9][0-9]*)"/) {$lastCursorPos = int($1);}
      next;
    }
    if(/Type="edit"/ && /Value="\[Ctrl.C\]"/ ) { next;}

#printf STDERR "Key1: %s", $_;
    if(/Type="edit"/) {
      if(/Text="([^"]*)"/) {DeleteText(MSunescape($1));}
      if(/Paste="([^"]*)"/) {InsertText(MSunescape($1));}
    }
    if(/Type="return"/) {InsertText("\n"); }
    if(/Type="delete"/) { 
      if(/Text="([^"]*)"/) {DeleteText(MSunescape($1));}
      else { 
        printf STDERR "Empty Text in delete: $_"; 
        DeleteText("#");
      }
    }
    if(/Type="insert"/) { 
      if(/Text="([^"]*)"/) { DeleteText(MSunescape($1));}
      if(/Value="([^"]*)"/) { InsertText(MSunescape($1));} 
      else { printf STDERR "Key: no inserted Value $_"; }
    }

# Plot operations    
    if($Verbose > 3){
      /Type="([^"]*)"/; my $type=$1;
      /Cursor="([^"]*)"/; my $cur=$1;
      printf STDERR "$type $cur\t"; 
      for(my $j=0; $j < $TextLength; $j++) {  printf STDERR "%s", $TEXT->{$j}{'c'};}
      printf STDERR "\n"; 
    }
  }
}

sub InsertText {
  my ($x) = @_;
  my ($j, $c, $l, $t);

  my $s = $_;
  my $X=[split(//, $x)];

#printf STDERR "InsertText1: $s$x\n";

  if($s =~ /Cursor="([0-9][0-9]*)"/) {$c = int($1);}
  else { printf STDERR "InsertText1: No Cursor in $s\n";}
  if($s =~ /Time="([0-9][0-9]*)"/)   {$t = int($1);}
  else { printf STDERR "InsertText1: No Time in $s\n";}

  if($t <= $lastKeyTime) { $t = $lastKeyTime+1; }

# make place for insertion in text 
  for($j=$TextLength; $j > $c; $j--) { $TEXT->{$j+$#{$X}}{'c'} = $TEXT->{$j-1}{'c'}; }
#  insert contents of $X in text 
  for($j=0; $j <= $#{$X}; $j++) { 
#    print STDERR "         ins   time:$t Log:$x($#{$X})\tLog:$j:$X->[$j]\n"; 
    $TEXT->{$c+$j}{'c'} = $X->[$j]; 
  }
  $TextLength += $#{$X} +1;


# produce keystroke event
  for($j=0; $j <= $#{$X}; $j++) {
    $KEY->{$t}{'t'} = "ins";
    $KEY->{$t}{'k'} = $X->[$j];
    if(/Cursor="([0-9][0-9]*)"/) {$KEY->{$t}{'c'} = $c+$j;}
    $t++;
  }
  $lastCursorPos = $c+$#{$X}+1;
  $lastKeyTime = $t;

}

## Delete
sub DeleteText {
  my ($x) = @_;
  my ($j, $c, $l, $t);

  my $s = $_;
  if($s =~ /Cursor="([0-9][0-9]*)"/) {$c = int($1);}
  else { printf STDERR "InsertText1: No Cursor in $s\n";}
  if($s =~ /Time="([0-9][0-9]*)"/)   {$t = int($1);}
  else { printf STDERR "InsertText1: No Time in $s\n";}

  # no text to delete (backspace at beginning delete at end of text)
  if($c < 0 || $c >= $TextLength) {return;}

  my $X=[split(//, $x)];
  $l = $#{$X}+1;

  if($t <= $lastKeyTime) {$t = $lastKeyTime+1;}

#printf STDERR "DeleteText2: time:$t text:$TextLength cur:$c chunk:$x length:$l/$#{$X}\n";

  # check inconsistencies between X (buffer) and TEXT (should be identical)
  my $i =0;
  for($j=$c; $j<$c+$l; $j++) {
#      print STDERR "         del   time:$t Log:$x($#{$X})\tLog:$i:$X->[$i]  eq  Text:$j:$TEXT->{$j}{'c'}\n"; 
    if($X->[$i] eq '#') { $X->[$i] = $TEXT->{$j}{'c'};}
    elsif($TEXT->{$j}{'c'} ne $X->[$i]) {
      printf STDERR "WARNING Delete time:$t cur:$j Char:%s\tLog:%s($#{$X})\tText:$j:%s\n\t", 
                     encode('utf8', $X->[$i]), encode('utf8', $x), encode('utf8', $TEXT->{$j}{'c'}); 
#      $X->[$i] = $TEXT->{$j}{'c'};
#      $TEXT->{$j}{'c'} = $X->[$i];
#      last;
      for (my $k=$j-10;$k<$j+10;$k++) { 
        if($k >= $TextLength) {last;}
        if($k == $j) {print STDERR " |";} 
        if(!defined($TEXT->{$k}{'c'})) {print STDERR "!$k!";}
        else { printf STDERR "%s", encode('utf8', $TEXT->{$k}{c});}
        if($k == $j) {print STDERR "| ";} 
      }
      print STDERR "\n"; 
      last;
    }
    elsif($Verbose > 1) { print STDERR "WARNING Delete time:$t cursor:$j buff:$i:%s\n", encode('utf8', $X->[$i]);}  
    $i++;
  }

  # track deletion in text 
  for($j=$c; $j<$TextLength-$l; $j++) {
    if($j+$l >= $TextLength) { last;}
#printf STDERR "DeleteText3: move %d:%s to %d:%s\n", $j+$l, $TEXT->{$j+$l}{'c'}, $j, $TEXT->{$j}{'c'};
    $TEXT->{$j}{'c'} = $TEXT->{$j+$l}{'c'};
  }

  # deletion sequence in text 
  for($j=$l-1; $j>=0; $j--) {
#printf STDERR "DeleteText3: %s %s\n", $TextLength, $c+$j;
    if($c+$j > $TextLength) {last;}
    $KEY->{$t}{'t'} = "del";
    $KEY->{$t}{'k'} = $X->[$j];
    if(/Cursor="([0-9][0-9]*)"/) {$KEY->{$t}{'c'} = $c + $j;}
    $t++;
  }
  $lastKeyTime = $t;
  $lastCursorPos = $c;

  if($TextLength > $c+$l) {$TextLength -= $l;}
  else {$TextLength = $c;}

}

##########################################################
# Check whether text was correctly reproduced
##########################################################

sub CheckForward {

  foreach my $f (sort {$a <=> $b} keys %{$CHR->{fin}}) {
    if($f>=$TextLength) {last;}
    if(!defined($TEXT->{$f})) {printf STDERR "CheckForward undefined TEXT: $f\n";d($CHR->{fin}{$f});next;}
    if($CHR->{fin}{$f}{'c'} ne $TEXT->{$f}{'c'}) {
      printf STDERR "CheckForward CHR unmatched cursor: $f >%s<\t>%s<\n", encode('utf8', $TEXT->{$f}{'c'}), encode('utf8',$CHR->{fin}{$f}{'c'}); 
      printf STDERR "Prod. TEXT:\t"; 
      foreach my $m (sort {$a <=> $b} keys %{$TEXT}) { 
        if($m <= $f-20) {next;} 
        if($m >= $f+20) {last;} 
        if($m >= $TextLength) {last;} 
        if($m == $f) {printf STDERR "#";} 
        printf STDERR "%s", encode('utf8', $TEXT->{$m}{'c'}); 
        if($m == $f) {printf STDERR "#";} 
      }
      printf STDERR "\n"; 
      printf STDERR "Final TEXT:\t"; 
      foreach my $m (sort {$a <=> $b} keys %{$CHR->{fin}}) { 
        if($m <= $f-20) {next;} 
        if($m >= $f+20) {last;} 
        if($m >= $TextLength) {last;} 
        if($m == $f) {printf STDERR "#";} 
        printf STDERR "%s", encode('utf8', $CHR->{fin}{$m}{'c'}); 
        if($m == $f) {printf STDERR "#";} 
      }
      printf STDERR "\n"; 
#      d($TEXT->{$f});
      next;
    }
  }
}

##########################################################
# Map CHR gaze and fixations on ST
##########################################################

sub MapTok2Chr {
  my $id=-1;

  foreach my $cur (sort {$a <=> $b} keys %{$CHR->{fin}}) { 
    if(defined($TOK->{fin}{$cur})) {
      $CHR->{fin}{$cur}{'tok'} = $TOK->{fin}{$cur}{tok}; 
      $id=$TOK->{fin}{$cur}{'id'};
    }
    $CHR->{fin}{$cur}{'id'} = $id;
  }

  $id=-1;
  foreach my $cur (sort {$a <=> $b} keys %{$CHR->{src}}) { 
#print STDERR "Map $k $s\n";
    if(defined($TOK->{src}{$cur})) {
      $CHR->{src}{$cur}{'tok'} = $TOK->{src}{$cur}{tok}; 
      $id=$TOK->{src}{$cur}{id};
    }
    $CHR->{src}{$cur}{'id'} = $id;
  }
}




##########################################################
# Map CHR gaze and fixations on ST
##########################################################

sub MapSource {
  my ($cur);

  ## initialise id in TEXT and CHR
  my $n = 0;
  my $c = 0;
  foreach $cur (sort {$a <=> $b} keys %{$CHR->{fin}}) { 
    if(!defined($TEXT->{$cur})) {printf STDERR "$opt_T: MapSource undefined TEXT cur: $cur\n";next;}
    if(!defined($TEXT->{$cur}{'c'})) {
      printf STDERR "$opt_T: MapSource undefined TEXT char at cur: $cur\n";
      d($TEXT->{$c});
      next;
    }
    if(!defined($CHR->{fin}{$cur}{'c'})) {
      printf STDERR "$opt_T: MapSource undefined CHR char at cur: $cur\n";
      d($CHR->{fin}{$cur});next;
    }
    if($CHR->{fin}{$cur}{'c'} ne $TEXT->{$cur}{'c'}) {
      printf STDERR "$opt_T: MapSource unmatched CHR cursor: $cur: TEXT:>%s<\tCHR:>%s<\n", 
             encode('utf8', $TEXT->{$cur}{'c'}), encode('utf8',$CHR->{fin}{$cur}{'c'}); 
      next;
    }
    if($CHR->{fin}{$cur}{'id'} != $n) { 
      $c=$cur; 
      $n=$CHR->{fin}{$cur}{'id'};
    }
    $TEXT->{$cur}{'id'} = $CHR->{fin}{$cur}{'id'};
    $TEXT->{$cur}{'wcur'} = $c;
#printf STDERR "MapSource $cur %s %s\n", $TEXT->{$cur}{'wcur'}, $TEXT->{$cur}{'id'}; 
  }

## TEXT and CHR should be identical, if not 
  $n=0;
  foreach $cur (sort {$a <=> $b} keys %{$TEXT}) { 
    if($cur>=$TextLength) {last;}
    
    if(!defined($TEXT->{$cur}{'id'})) {
      printf STDERR "$opt_T: MapSource undefined TEXT id $cur\t%s setting to cur:$n wcur:$c\n", encode('utf8', $TEXT->{$cur}{'c'});
      $TEXT->{$cur}{'id'} = $n;
      $TEXT->{$cur}{'wcur'} = $c;
    } 
    else {
      $n = $TEXT->{$cur}{'id'};
      $c = $TEXT->{$cur}{'wcur'};
    }
  }

  ## initialise TEXT words in KEY
  foreach $cur (sort {$a <=> $b} keys %{$EYE}) { 
    if($EYE->{$cur}{'w'} != 1) {next;}
    $c = $EYE->{$cur}{'c'};
    $EYE->{$cur}{'id'}= $CHR->{src}{$c}{'id'}; 
  }

  ## initialise TEXT words in KEY
  foreach $cur (sort {$a <=> $b} keys %{$FIX}) { 
    if($FIX->{$cur}{'w'} != 1) {next;}
    $c = $FIX->{$cur}{'c'};
    $FIX->{$cur}{'id'}= $CHR->{src}{$c}{'id'}; 
  }
}


############################################################
# Key-to-ST mapping
############################################################

sub MapTarget {
  my ($k, $j, $c);
  my ($F, $E);

  if(defined($FIX)) { $F = [sort {$b <=> $a} keys %{$FIX}];}
  if(defined($EYE)) { $E = [sort {$b <=> $a} keys %{$EYE}];}
  my $e=0; # time index of last eye event
  my $f=0; # time index of last fix event

  my $id=-1; my $wcur=-1;

  ## loop through keystrokes from end to start
  foreach $k (sort {$b <=> $a} keys %{$KEY}) {
    $c = $KEY->{$k}{'c'};

    ## Assign Word ID to FIX samples in target window between time $f and time $k
    while($f <= $#{$F} && $F->[$f] > $k) {
      if($FIX->{$F->[$f]}{'w'} != 2) { $f++; next;}

      my $cur = $FIX->{$F->[$f]}{'c'}; # cursor
      if(!defined($TEXT->{$cur}{'id'})) {
        printf STDERR "Undef id in TEXT cur:$cur $TextLength\n"; 
        d($FIX->{$F->[$f]});
      }
      elsif($FIX->{$F->[$f]}{'c'} >= $TextLength) {
        if($Verbose) {
          printf STDERR "Target FIX at time:$F->[$f] cur:$FIX->{$F->[$f]}{'c'} >= TEXT:$TextLength\n"; 
        }
        $cur = $TextLength-1;
      }
      ## This is the target ==> source mapping
      $FIX->{$F->[$f]}{'id'} = $TEXT->{$cur}{'id'}; 
      $f++; 
    }

    ## Assign Word ID to EYE samples in target window between time $e and time $k
    while($e <= $#{$E} && $E->[$e] > $k) {
      my $e1 = $E->[$e];
      if($EYE->{$E->[$e]}{'w'} == 2) {
        my $cur = $EYE->{$E->[$e]}{'c'};

        if(!defined($TEXT->{$cur}{'wcur'})) {
          printf STDERR "Undef id in TEXT cur:$cur $TextLength\n"; 
        }
        if($EYE->{$e1}{'c'} >= $TextLength) {
          if($Verbose) {printf STDERR "Target EYE at time:$e1 cur:$EYE->{$e1}{'c'} >= TEXT:$TextLength\n"; }
 	  $cur = $TextLength-1;
        }

        $EYE->{$e1}{'id'} = $TEXT->{$cur}{'id'}; 
      }
      $e++; 
    }

###########################################
# Key -> word mapping
###########################################

    if($KEY->{$k}{'t'} eq "ins") {
# Check Consistency of Keys and TEXT
      if(!defined($TEXT->{$c}{'c'})) {printf STDERR "MapTarget undefined ins char: cur:$c $KEY->{$k}{'k'}\n"; next;}
      if(!defined($TEXT->{$c}{'id'})){printf STDERR "MapTarget undefined ins id:   cur:$c $KEY->{$k}{'k'}\n"; next;}

      if($KEY->{$k}{'k'} ne $TEXT->{$c}{'c'}) {
        printf STDERR "MapTarget no match: $c %s\t%s\n", encode('utf8', $KEY->{$k}{'k'}), encode('utf8', $TEXT->{$c}{'c'}); 
#        foreach my $m (sort {$a <=> $b} keys %{$TEXT}) { 
#          if($m >= $TextLength) {last;} 
#	  if($m == $c) {printf STDERR "#";} 
#	  printf STDERR "$TEXT->{$m}{'c'}"; 
#        }
#        printf STDERR "\n"; 
        next;
      }
# remember last id
      $id = $KEY->{$k}{'id'} = $TEXT->{$c}{'id'};
      $wcur = $KEY->{$k}{'wcur'} = $TEXT->{$c}{'wcur'};
      for($j=$c; $j<$TextLength-1; $j++) { 
        $TEXT->{$j}{'c'} = $TEXT->{$j+1}{'c'}; 
        $TEXT->{$j}{'id'} = $TEXT->{$j+1}{'id'}; 
        $TEXT->{$j}{'wcur'} = $TEXT->{$j+1}{'wcur'}; 
      }
      $TextLength--;
    }

    elsif($KEY->{$k}{'t'} eq "del") {

      if(!defined($TEXT->{$c}) || !defined($TEXT->{$c}{'id'})) {
        printf STDERR "MapTarget undefined del id:   cur:$c %s\n", encode('utf8',$KEY->{$k}{'k'}); 
        my $c1 =$c;
        while(!defined($TEXT->{$c1}) || !defined($TEXT->{$c1}{'id'})) {$c1 --;}
        $TEXT->{$c}{'wcur'} = $TEXT->{$c1}{'wcur'};
        $TEXT->{$c}{'id'} = $TEXT->{$c1}{'id'};
        $TEXT->{$c}{'c'} = $KEY->{$k}{'k'};
        $TextLength++;
        next;
      }
      elsif(defined($TEXT->{$c-1}) && defined($TEXT->{$c-1}{id}) && 
        $TEXT->{$c-1}{'id'} == $TEXT->{$c}{'id'}) { 
        $id = $TEXT->{$c}{'id'}; 
        $wcur = $TEXT->{$c}{'wcur'};
      }
      ## new word
      elsif(defined($TEXT->{$c-1}) && defined($TEXT->{$c-1}{id}) &&
        $TEXT->{$c-1}{'id'} > $id || $TEXT->{$c}{'id'} < $id) {
        if($TEXT->{$c}{'c'} =~ /\s/)      { $id = $TEXT->{$c-1}{'id'}; $wcur = $TEXT->{$c-1}{'wcur'};}
	elsif($TEXT->{$c-1}{'c'} =~ /\s/) { $id = $TEXT->{$c}{'id'}; $wcur = $TEXT->{$c}{'wcur'};}
	else { $id = $TEXT->{$c}{'id'}; $wcur = $TEXT->{$c}{'wcur'};}
      }
      elsif($id == -1) { $id = $TEXT->{$c}{'id'}; $wcur = $TEXT->{$c}{'wcur'};}

#printf STDERR "DELETED: cur:$c id:$id  $TEXT->{$c-1}{'id'}:$TEXT->{$c-1}{'c'}  $TEXT->{$c}{'id'}:$TEXT->{$c}{'k'}  ins:$KEY->{$k}{'k'} \n"; 
#for (my $i=$c-3; $i<$c+3; $i++) { printf STDERR "$TEXT->{$i}{'c'}";}
#printf STDERR "\n";


      for($j=$TextLength; $j>$c; $j--) { 
        $TEXT->{$j}{'id'} = $TEXT->{$j-1}{'id'}; 
        $TEXT->{$j}{'wcur'} = $TEXT->{$j-1}{'wcur'}; 
        $TEXT->{$j}{'c'} = $TEXT->{$j-1}{'c'}; 
      }
      $KEY->{$k}{'id'}=$TEXT->{$c}{'id'} = $id;
      $KEY->{$k}{'wcur'}=$TEXT->{$c}{'wcur'} = $wcur;
      $TEXT->{$c}{'c'} = $KEY->{$k}{'k'};

      $TextLength++;
    }
    else { printf STDERR "ERROR undefined KEYSTROKE:\n"; d($KEY->{$k}); }
  }

### fixations after end of typing
  while($f <= $#{$F}) {
    if($FIX->{$F->[$f]}{'w'} == 2) {
      my $cur = $FIX->{$F->[$f]}{'c'}; 
      $FIX->{$F->[$f]}{'id'} = $TEXT->{$cur}{'id'}; 
    }
    $f++;
  }

### gaze samples after end of typing
  while($e <= $#{$E}) {
    if($EYE->{$E->[$e]}{'w'} == 2) {
      my $cur = $EYE->{$E->[$e]}{'c'};
      $EYE->{$E->[$e]}{'id'} = $TEXT->{$cur}{'id'}; 
    }
    $e++; 
  }
}


################################################
## CHECK whether backwards reproduces TranslationText
################################################

sub CheckBackward {

  foreach my $k (sort {$a <=> $b} keys %{$CHR->{tra}}) {
    if(!defined($CHR->{tra}{$k}))     {
      printf STDERR "CheckBackward CHR: $k $CHR->{tra}{$k}\n"; 
      next;
    }
    if($CHR->{tra}{$k}{'c'} ne $TEXT->{$k}{'c'}) {
      printf STDERR "CheckBackward CHR: $k %s\t%s\n", encode('utf8', $TEXT->{$k}{'c'}), encode('utf8',$CHR->{tra}{$k}{'c'}); 
      next;
    }
  }
}

################################################
#  PRINTING
################################################

sub FixModTable {
  my ($m, $ord);

  foreach my $i (sort {$b<=>$a} keys %{$TRANSLOG}) { if($TRANSLOG->{$i} =~ /<\/LogFile>/) {$m=$i;last; }}

  $TRANSLOG->{$m++} ="  <Fixations>\n";

  foreach my $t (sort {$a<=>$b} keys %{$FIX}) {
    my $id=0;

    if(!defined($FIX->{$t}{id})) { 
      next;
      print STDERR "$fn FIX Undefined $t\n";
      d($FIX->{$t});
    }
    if($FIX->{$t}{w} == 1) {$id=$FIX->{$t}{id};}
    elsif($FIX->{$t}{w} == 2) {$id=$FIX->{$t}{id};}
    else {next;}

    $TRANSLOG->{$m++} = "    <Fix time=\"$t\" win=\"$FIX->{$t}{w}\" cur=\"$FIX->{$t}{c}\" dur=\"$FIX->{$t}{d}\" id=\"$id\" />\n";
  }
  $TRANSLOG->{$m++} ="  </Fixations>\n";

  $TRANSLOG->{$m++} ="  <Modifications>\n";
  foreach my $t (sort {$a<=>$b} keys %{$KEY}) {
    if(!defined($KEY->{$t}{id})) { 
      print STDERR "KEY Undefined $t\n";
      d($KEY->{$t});
      next;
    }

    my $s = '';
    if(defined($ALN->{'tid'}) &&
       defined($ALN->{'tid'}{$KEY->{$t}{'id'}})) { 
      my $k = 0;
      foreach my $sid (sort  {$a <=> $b} keys %{$ALN->{'tid'}{$KEY->{$t}{'id'}}{'sid'}}) {
        if($k >0) {$s .= "+";}
        $s .= $sid;
        $k++;
      }
    }
    my $chr = MSescape($KEY->{$t}{k});
    $TRANSLOG->{$m++} = "    <Mod time=\"$t\" type=\"$KEY->{$t}{t}\" cur=\"$KEY->{$t}{c}\" chr=\"$chr\" sid=\"$s\" id=\"$KEY->{$t}{id}\" />\n";
  }
  $TRANSLOG->{$m++} ="  </Modifications>\n";
  $TRANSLOG->{$m++} ="<\/FinalToken>\n";

}

sub PrintTranslog{
  my ($fn) = @_;
  my $m;

  open(FILE, '>:encoding(utf8)', $fn) || die ("cannot open file $fn");

  foreach my $k (sort {$a<=>$b} keys %{$TRANSLOG}) { print FILE "$TRANSLOG->{$k}"; }
}

