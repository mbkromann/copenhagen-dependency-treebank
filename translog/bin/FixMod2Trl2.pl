#!/usr/bin/perl -w

use strict;
use warnings;

use Encode qw(encode decode);
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

# Escape characters 
my $map = { map { $_ => 1 } split( //o, "\\<> \t\n\r\f\"" ) };

use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

my $usage =
  "Translog (incl src, tgt, atag) file to Treex: \n".
  "  -T in: Atag.xml file \n".
  "  -O out Write output <filename>\n".
  "Options:\n".
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
my $ID2Seg;

die $usage if defined($opt_h);
die $usage if not defined($opt_T);
die $usage if not defined($opt_O);

  my $T = ReadTranslog($opt_T);

#my $xxx =0;
  foreach my $seg (sort {$a <=> $b} keys %{$T}) { 
    $FIX=$EYE=$KEY=$CHR=$TOK=$TEXT=undef;
    if(!defined($T->{$seg}{SEG}{1})) { print STDERR "No Source SEG $seg\n"; next;}
    if(!defined($T->{$seg}{SEG}{2})) { print STDERR "No Target SEG $seg\n"; next;}
    if(!defined($T->{$seg}{SEG}{3})) { print STDERR "No Final SEG $seg\n"; next;}

print STDERR "Segment source:$seg $T->{$seg}{SEG}{1}{seg} target:$seg $T->{$seg}{SEG}{2}{seg} final: $seg $T->{$seg}{SEG}{3}{seg}\n";
#print STDERR "Segment source:$seg $T->{$seg}{SEG}{1}{text}\n target:$seg $T->{$seg}{SEG}{2}{text}\n final: $seg $T->{$seg}{SEG}{3}{text}\n";

    my $S = [split(//, $T->{$seg}{SEG}{1}{text})];
    for (my $i = 0; $i<=$#{$S}; $i++) { $CHR->{src}{$i}{'c'} = $S->[$i];}

    $S = [split(//, $T->{$seg}{SEG}{2}{text})];
    $TextLength = $#{$S}+1;
    for (my $i = 0; $i<=$#{$S}; $i++) { $CHR->{tra}{$i}{'c'} = $S->[$i];}
    for (my $i = 0; $i<=$#{$S}; $i++) { $TEXT->{$i}{'c'} = $S->[$i];}
    $S = [split(//, $T->{$seg}{SEG}{3}{text})];
    for (my $i = 0; $i<=$#{$S}; $i++) { $CHR->{fin}{$i}{'c'} = $S->[$i];}

#    $xxx++;
#    if($xxx == 1) {next;}

#print STDERR "CHR fin:\n";
#d($CHR->{fin});

    $EYE=$T->{$seg}{EYE};
    $FIX=$T->{$seg}{FIX};
    $TOK=$T->{$seg}{TOK};
#print STDERR "TOK fin:\n";
#d($TOK->{fin});

    KeyLogAnalyse($T->{$seg}{KEY});

    CheckForward();
    MapTok2Chr();
    MapSource();
    UnmapTEXT();
    MapTarget();
#  CheckBackward ();

    FixModTable($seg);
  }
  PrintTranslog($opt_O);
exit;

############################################################
# escape
############################################################

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
#  $in =~ s/ /&nbsp;/g;
  return $in;
}



##########################################################
# Read Translog Logfile
##########################################################

## SourceText Positions
sub ReadTranslog {
  my ($fn) = @_;
  my ($type, $time, $cur);

  my $T = {};
  my $key = 0;
  my $F = '';
  my ($lastTime, $t, $lastCursor, $c);

#  if($fn ne '-') {
#    open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
#    STDIN->fdopen(\*FILE,  'r') or die $!;
#  }

  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  if($Verbose) {printf STDERR "ReadTranslog Reading: $fn\n";}

  $type = 0;
  my $log = 0;
  my $m = 0;
  my $seg = 0;
  my $Seg2ID;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;
    $TRANSLOG->{$log++} = $_;

    if(/<Events>/) {$type =4; }
    elsif(/<SourceText[ >]/) {$type =1; $m=0;}
    elsif(/<TargetText[ >]/) {$type =2; $m=0;}
    elsif(/<FinalText[ >]/)  {$type =3; $m=0;}
    elsif(/<Alignment[ >]/)   {$type =6;}
    elsif(/<SourceToken[ >]/){$type =7;}
    elsif(/<FinalToken[ >]/) {$type =8;}
	
#print STDERR "Segment: $m\t$seg\t$type\t$_";

   if(($type == 1 || $type == 2 || $type == 3)  && /<[Ss]eg/) {
      my ($text) = $_ =~ />([^<]*)</;
      my ($seg) = $_ =~ /Id="([^"]*)/i;
#print STDERR "Segment: $m\t$seg\t$type\t$text\t$_";
      $T->{$m}{SEG}{$type}{text} = $text;
      $T->{$m}{SEG}{$type}{seg} = $seg;
      $Seg2ID->{$seg}=$m;
      $ID2Seg->{$m}{$type}=$seg;
      $m ++;
    }

    elsif($type == 4 && /<Eye/) {
      if(/segId="([^"]*)"/i) { 
        if(defined($Seg2ID->{$1})) {$seg=$Seg2ID->{$1}; }
#        else {print STDERR "Eye: undefined seg $_";}
      }
      if(/Time="([0-9][0-9]*)"/)  {$time =$1;}
      if(/TT="([0-9][0-9]*)"/)    {$T->{$seg}{EYE}{$time}{'tt'} = $1;}
      if(/Win="([0-9][0-9]*)"/)   {$T->{$seg}{EYE}{$time}{'w'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'w'} = 0;}
      if(/Xl="([-0-9][0-9]*)"/)    {$T->{$seg}{EYE}{$time}{'xl'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'xl'} = 0;}
      if(/Yl="([-0-9][0-9]*)"/)    {$T->{$seg}{EYE}{$time}{'yl'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'yl'} = 0;}
      if(/pl="([0-9.][0-9.]*)"/)  {$T->{$seg}{EYE}{$time}{'pl'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'pl'} = 0;}
      if(/Xr="([-0-9][0-9]*)"/)    {$T->{$seg}{EYE}{$time}{'xr'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'xr'} = 0;}
      if(/Yr="([-0-9][0-9]*)"/)    {$T->{$seg}{EYE}{$time}{'yr'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'yr'} = 0;}
      if(/pr="([0-9.][0-9.]*)"/)  {$T->{$seg}{EYE}{$time}{'pr'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'pr'} = 0;}
      if(/Cursor="([0-9][0-9]*)"/){$T->{$seg}{EYE}{$time}{'c'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'c'} = 0;}
      if(/Xc="([-0-9][0-9]*)"/)    {$T->{$seg}{EYE}{$time}{'xc'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'xc'} = 0;}
      if(/Yc="([-0-9][0-9]*)"/)    {$T->{$seg}{EYE}{$time}{'yc'} = $1;}
      else{$T->{$seg}{EYE}{$time}{'yc'} = 0;}
    }

    elsif($type == 4 && /<Fix/) {
# Skip End-of-Fixation
      if(!/Block="([0-9][0-9]*)"/) {next;}
      elsif($1 == 0) {next;}

      if(/segId="([^"]*)"/i) { 
        if(defined($Seg2ID->{$1})) {$seg=$Seg2ID->{$1}; }
#        else {print STDERR "Fix: undefined seg $_";}
      }
      if(/Time="([^"]*)"/)  {$time =$1;}
      if($time < 0) {next;}
      if(/Cursor="([0-9][0-9]*)"/){$T->{$seg}{FIX}{$time}{'c'} = $1;}
      else {$T->{$seg}{FIX}{$time}{'c'} = 0;}
      if(/Block="([0-9][0-9]*)"/) {$T->{$seg}{FIX}{$time}{'b'} = $1;}
      else {$T->{$seg}{FIX}{$time}{'b'} = 0;}
      if(/Win="([0-9][0-9]*)"/)   {$T->{$seg}{FIX}{$time}{'w'} = $1;}
      else {$T->{$seg}{FIX}{$time}{'w'} = 0;}
      if(/Dur="([0-9][0-9]*)"/)   {$T->{$seg}{FIX}{$time}{'d'} = $1;}
      else {$T->{$seg}{FIX}{$time}{'d'} = 0;}
      if(/X="([-0-9][0-9]*)"/)     {$T->{$seg}{FIX}{$time}{'x'} = $1;}
      else {$T->{$seg}{FIX}{$time}{'x'} = 0;}
      if(/Y="([-0-9][0-9]*)"/)     {$T->{$seg}{FIX}{time}{'y'} = $1;}
      else {$T->{$seg}{FIX}{$time}{'y'} = 0;}

    }
    elsif($type == 4 && /<Key/) {  
      if(/segId="([^"]*)"/i) { 
        if(defined($Seg2ID->{$1})) {$seg=$Seg2ID->{$1}; }
        else {print STDERR "Key: undefined seg $_";}
      }
#print STDERR "KEY $seg\t$_";
      $T->{$seg}{KEY}{$key++} = $_; 
    }
    elsif($type == 5) {  $F .= $_; }
    elsif($type == 6 && /<Align /) {
#print STDERR "ALIGN: $_";
      my ($si, $ti);
      if(/sid="([^\"]*)"/) {$si =$1;}
      if(/tid="([^\"]*)"/)  {$ti =$1;}
      $ALN->{'tid'}{$ti}{'sid'}{$si} ++;
      $ALN->{'sid'}{$si}{'tid'}{$ti} ++;
    }
    elsif($type == 7 && /<Token/) {
      if(/segId="([^"]*)"/i) { 
        if(defined($Seg2ID->{$1})) {$seg=$Seg2ID->{$1}; }
        else {print STDERR "Token$type:Undefined seg $_";}
      }
      if(/cur="([0-9][0-9]*)"/) {$cur =int($1);}
      if(/tok="([^"]*)"/)   {$T->{$seg}{TOK}{src}{$cur}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$T->{$seg}{TOK}{src}{$cur}{space} = MSunescape($1);}
      if(/id="([^"]*)"/)    {$T->{$seg}{TOK}{src}{$cur}{id} = int($1);}
    }

    elsif($type == 8 && /<Token/) {
      if(/segId="([^"]*)"/i) { 
        if(defined($Seg2ID->{$1})) {$seg=$Seg2ID->{$1}; }
        else {print STDERR "Token$type: undefined seg $1 $_";}
      }
      if(/cur="([0-9][0-9]*)"/) {$cur =int($1);}
      if(/tok="([^"]*)"/)   {$T->{$seg}{TOK}{fin}{$cur}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$T->{$seg}{TOK}{fin}{$cur}{space} = MSunescape($1);}
      if(/id="([^"]*)"/)    {$T->{$seg}{TOK}{fin}{$cur}{id} = int($1);}
    }

    if(/<\/FinalText>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/Events>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/TranslationChar>/) {$type =0; }
    if(/<\/TargetTextChar>/) {$type =0; }
    if(/<\/FinalTextChar>/) {$type =0; }
    if(/<\/FinalText>/) {$type =0; }
    if(/<\/Alignment>/) {$type =0; }
    if(/<\/SourceToken>/){$type =0; }
    if(/<\/FinalToken>/) {$type =0; }
  }
  close(FILE);

#foreach my $f (sort {$a <=> $b} keys %{$TEXT}) { print STDERR "$TEXT->{$f}{c}" }
#printf STDERR "\n";

  return $T;
}



##########################################################
# Parse Keystroke Log
##########################################################

## map all keystrokes on ins and del
sub KeyLogAnalyse {
  my ($K) = @_;

#  print STDERR "KEYLOG: $TextLength\ntext:\t\ ";
#  for(my $j=0; $j<$TextLength; $j++) { print STDERR "$TEXT->{$j}{'c'}";}
#  print STDERR "<\n";

  $lastKeyTime=0;
  foreach my $f (sort {$a <=> $b} keys %{$K}) {
    $_ = $K->{$f};

#print STDERR "\t$_";

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
  my ($Value) = @_;
  my ($j, $c, $l, $t);

  my $s = $_;
  my $X=[split(//, $Value)];

  if($s =~ /Cursor="([0-9][0-9]*)"/) {$c = int($1);}
  else { printf STDERR "InsertText1: No Cursor in $s\n";}
  if($s =~ /Time="([0-9][0-9]*)"/)   {$t = int($1);}
  else { printf STDERR "InsertText1: No Time in $s\n";}

#print STDERR "INSERT $lastKeyTime\t$_";

  if($t <= $lastKeyTime) { $t = $lastKeyTime+1; }

# make place for insertion in text 
  for($j=$TextLength; $j > $c; $j--) { 
    $TEXT->{$j+$#{$X}}{'c'} = $TEXT->{$j-1}{'c'}; 
  }
#  insert contents of $X in text 
  for($j=0; $j <= $#{$X}; $j++) { 
#    print STDERR "         ins   time:$t Log:$Value($#{$X})\tLog:$j:$X->[$j]\n"; 
    $TEXT->{$c+$j}{'c'} = $X->[$j]; 
    $KEY->{$t}{'t'} = "ins";
    $KEY->{$t}{'k'} = $X->[$j];
    if(/Cursor="([0-9][0-9]*)"/) {$KEY->{$t}{'c'} = $c+$j;}
#print STDERR "InsertText1: $t\tv:$Value\tchar:$X->[$j]\n";
    $t++;
  }
  $TextLength += $#{$X} +1;

  $lastCursorPos = $c+$#{$X}+1;
  $lastKeyTime = $t;

### Debugging
#  if($s =~ /Time="([0-9][0-9]*)"/)   {$t = int($1);}
#  print STDERR "ins:$t\t$Value\t>";
#  for($j=0; $j<$TextLength; $j++) { print STDERR "$TEXT->{$j}{'c'}";}
#  print STDERR "<\n";

}

## Delete
sub DeleteText {
  my ($Value) = @_;
  my ($j, $c, $l, $t);

  my $s = $_;
  if($s =~ /Cursor="([0-9][0-9]*)"/) {$c = int($1);}
  else { printf STDERR "InsertText1: No Cursor in $s\n";}
  if($s =~ /Time="([0-9][0-9]*)"/)   {$t = int($1);}
  else { printf STDERR "InsertText1: No Time in $s\n";}

#print STDERR "DELETE $lastKeyTime\t$Value\t$_";

# no text to delete (backspace at beginning delete at end of text)
#  if($c == 0 && $s =~ /Value="\[Back\]"/) { printf STDERR "DeleteText: Backspace skipped at beginning of Text\n"; return;}
#  if($c ==  $TextLength-1 && $s =~ /Value="\[Delete\]"/) { printf STDERR "DeleteText: Delete skipped at end of Text\n"; return;}

  if($c < 0 || $c >= $TextLength) {
    printf STDERR "DeleteText Length mismatch: Time:$t TextLength:$TextLength Cursor:$c\n";
    return;
  }

  my $X=[split(//, $Value)];

  if($t <= $lastKeyTime) {$t = $lastKeyTime+1;}

#printf STDERR "DeleteText2: time:$t text:$TextLength cur:$c chunk:$Value length:$l/$#{$X}\n";

  # check inconsistencies between X (buffer) and TEXT (should be identical)
  my $i =0;
  for($j=$c; $j<=$c+$#{$X}; $j++) {
#      print STDERR "         del   time:$t Log:$Value($#{$X})\tLog:$i:$X->[$i]  eq  Text:$j:$TEXT->{$j}{'c'}\n"; 
    if($Value  =~ /\#/) { $X->[$i] = $TEXT->{$j}{'c'};}
    elsif($TEXT->{$j}{'c'} ne $X->[$i]) {

      my $offs = SearchDelChar($TEXT, $j, $X, $i);
      for (my $k=0; $k <$offs; $k++) {unshift(@{$X}, '#')}
      printf STDERR "WARNING Delete time:$t cur:$j inserted:$offs\tLog:$Value($#{$X})\tText:$j:$TEXT->{$j}{'c'}\t$offs\n\t"; 
      for (my $k=$j-10;$k<$j+10;$k++) { 
        if($k >= $TextLength) {last;}
        if($k == $j) {print STDERR " |";} 
        if(defined($TEXT->{$k}{'c'})) { printf STDERR "%s", $TEXT->{$k}{c};}
        if($k == $j) {print STDERR "| ";} 
      }
      print STDERR "\n"; 
      last;
    }
    elsif($Verbose > 1) { print STDERR "WARNING Delete time:$t cursor:$j buff:$i:%s\n", $X->[$i];}  
    $i++;
  }
  $l = $#{$X}+1;

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

### Debugging
#  if($s =~ /Time="([0-9][0-9]*)"/)   {$t = int($1);}
#  print STDERR "del:$t\t$Value\t>";
#  for($j=0; $j<$TextLength; $j++) { print STDERR "$TEXT->{$j}{'c'}";}
#  print STDERR "<\n";

}

##############################################################
# Check whether final Text CHR was correctly reproduced (TEXT) 
##############################################################

sub CheckForward {
  my $keyOff = 0;

#print STDERR "CheckForward: $TextLength\n";

  for (my $f=0; $f<$TextLength; $f++) {
    if(!defined($CHR->{fin}{$f}) && !defined($TEXT->{$f})) { $TextLength = $f; last;}
    if(!defined($CHR->{fin}{$f})) {
      printf STDERR "CheckForward undefined CHR: cursor: $f\t>$TEXT->{$f}{c}<\n";
      next;
    }
    if(!defined($TEXT->{$f})) {printf STDERR "CheckForward undefined TEXT cursor: $f\n";d($CHR->{fin}{$f});last;}
    if(!defined($TEXT->{$f}{c})) {printf STDERR "CheckForward undefined TEXT char:\n";d($TEXT->{$f});}

#     $TEXT->{$f}{'add'} += $keyOff;
    if($CHR->{fin}{$f}{'c'} ne $TEXT->{$f}{'c'}) {
      my $t = SearchSubstring($f);
      printf STDERR "CheckForward unmatched CHR cursor: $f offset:$t >%s<\t>%s<\n", $TEXT->{$f}{'c'}, $CHR->{fin}{$f}{'c'}; 
      printf STDERR "Prod. TEXT:\t"; 
      foreach my $m (sort {$a <=> $b} keys %{$TEXT}) { 
        if($m <= $f-10) {next;} 
        if($m < 0) {next;}
        if($m >= $f+10) {last;} 
        if($m >= $TextLength) {last;} 
        if($m == $f) {printf STDERR "|";} 
        printf STDERR "$TEXT->{$m}{'c'}"; 
        if($m == $f) {printf STDERR "|";} 
      }
      printf STDERR "\n"; 

      if($t > 0) { 
        for(my $j=$TextLength-1; $j>=$f; $j--) {$TEXT->{$j+$t}{'c'} = $TEXT->{$j}{'c'};}
        for(my $j=0; $j<$t; $j++) { $TEXT->{$j+$f}{'c'} = $CHR->{fin}{$j+$f}{'c'};  }
        $TextLength += $t;
        $TEXT->{$f}{'add'} = $t *-1;
        $f+=$t-1;
      }
      if($t < 0) { 
        for(my $j=$f; $j<$TextLength+$t; $j++) { $TEXT->{$j}{'c'} = $TEXT->{$j-$t}{'c'};}
        $TextLength += $t;
        $TEXT->{$f}{'add'} = $t *-1;
      }
      $keyOff += $t;

      printf STDERR "New   TEXT:\t"; 
      foreach my $m (sort {$a <=> $b} keys %{$TEXT}) { 
        if($m <= $f-10) {next;} 
        if($m < 0) {next;}
        if($m >= $f+10) {last;} 
        if($m >= $TextLength) {last;} 
        if($m == $f) {printf STDERR "|";} 
        printf STDERR "$TEXT->{$m}{'c'}"; 
        if($m == $f) {printf STDERR "|";} 
      }
      printf STDERR "\n"; 
      printf STDERR "Final TEXT:\t"; 
      foreach my $m (sort {$a <=> $b} keys %{$CHR->{fin}}) { 
        if($m <= $f-10) {next;} 
        if($m < 0) {next;}
        if($m >= $f+10) {last;} 
        if($m >= $TextLength) {last;} 
        if($m == $f) {printf STDERR "|";} 
        print STDERR "$CHR->{fin}{$m}{'c'}"; 
        if($m == $f) {printf STDERR "|";} 
      }
      printf STDERR "\n"; 
#      d($TEXT->{$f});
      next;
    }
  }
}

sub SearchSubstring{
  my ($f) = @_;

  for (my $t=0; $t<5; $t++) { 
    for (my $c=0; $c<5; $c++) { 
      if(matchSubstring($f+$t, $f+$c)) { return $c-$t;}
  }  }  
  return 0;
}

sub matchSubstring{
  my ($txt, $chr) = @_;

  for (my $i=0; $i < 5; $i++) {
     if(!defined($CHR->{fin}{$chr+$i}) || 
        !defined($TEXT->{$txt+$i}) ||
        ($CHR->{fin}{$chr+$i}{'c'} ne $TEXT->{$txt+$i}{'c'})) {return 0;}
  } 
  return 1;
}

sub SearchDelChar {
   my ($Text, $txt, $X, $x) = @_;

  for (my $t=0; $t<5; $t++) {
    my $found = 1;
    for (my $c=0; $c+$x<=$#{$X}; $c++) {
#print STDERR "SearchDelChar: txt:$txt X:$#{$X} x:$x t:$t c:$c $TEXT->{$txt+$t}{c} $X->[$c+$x]\n";
       if(!defined($TEXT->{$txt+$t+$c}) ||
         ($X->[$c+$x] ne $TEXT->{$txt+$t+$c}{'c'})) {$found = 0;last;}
    }
    if($found == 1) {return $t}
  }
  return 0;
}



##########################################################
# Map CHR gaze and fixations on ST
##########################################################

sub MapTok2Chr {
  my $id=-1;

# assign token ID to char positions
  foreach my $cur (sort {$a <=> $b} keys %{$CHR->{fin}}) { 
    if(defined($TOK->{fin}{$cur})) {
      $CHR->{fin}{$cur}{'tok'} = $TOK->{fin}{$cur}{tok}; 
      $id=$TOK->{fin}{$cur}{'id'};
#print STDERR "MapTok2Chr cur:$cur id:$id\n";
#d($TOK->{fin}{$cur});
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

### map token id from Final text ($CHR->{fin}{$cur}{'id'}) on ireconstructed TEXT
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
             $TEXT->{$cur}{'c'}, $CHR->{fin}{$cur}{'c'}; 
#      next;
    }
    if($CHR->{fin}{$cur}{'id'} != $n) { 
      $c=$cur; 
      $n=$CHR->{fin}{$cur}{'id'};
    }
    $TEXT->{$cur}{'id'} = $CHR->{fin}{$cur}{'id'};
#printf STDERR "MapSource cur:$cur id:%s\n", $TEXT->{$cur}{'id'}; 
  }

  ## make sure all TEXT chars have an id 
  ## assume previous id if not
  $n=0;
  foreach $cur (sort {$a <=> $b} keys %{$TEXT}) { 
    if($cur>=$TextLength) {last;}
    if($cur<0) {next;}
    
    if(!defined($TEXT->{$cur}{'id'})) {
      print STDERR "$opt_T: MapSource undefined TEXT\t>$TEXT->{$cur}{'c'}< setting cur:$cur to id:$n\n";
##      d($TEXT->{$cur});
      $TEXT->{$cur}{'id'} = $n;
    } 
    else {
      $n = $TEXT->{$cur}{'id'};
    }
  }

  ## initialise word id in Eye data on ST
  foreach $cur (sort {$a <=> $b} keys %{$EYE}) { 
    if($EYE->{$cur}{'w'} != 1) {next;}
    $c = $EYE->{$cur}{'c'};
    $EYE->{$cur}{'id'}= $CHR->{src}{$c}{'id'}; 
  }

  ## initialise word id in Fix data on ST
  foreach $cur (sort {$a <=> $b} keys %{$FIX}) { 
    if($FIX->{$cur}{'w'} != 1) {next;}
    $c = $FIX->{$cur}{'c'};
    $FIX->{$cur}{'sid'}= $CHR->{src}{$c}{'id'}; 
  }
}

sub UnmapTEXT {

  foreach my $f (sort {$b <=> $a} keys %{$TEXT}) {
    if(!defined($TEXT->{$f}{'add'})) { next;}
    my $t = $TEXT->{$f}{'add'};

      printf STDERR "Map  TEXT:\t";
      foreach my $m (sort {$a <=> $b} keys %{$TEXT}) {
        if($m <= $f-10) {next;}
        if($m < 0) {next;}
        if($m >= $f+10) {last;}
        if($m >= $TextLength) {last;}
        if($m == $f) {printf STDERR "|";}
        printf STDERR "$TEXT->{$m}{'c'}";
        if($m == $f) {printf STDERR "|";}
      }
      printf STDERR "\n";

    if($t > 0) {
      my $id = $TEXT->{$f}{id};
      for(my $j=$TextLength-1; $j>=$f; $j--) {$TEXT->{$j+$t} = $TEXT->{$j}; $TEXT->{$j}={}}
      for(my $j=0; $j<$t; $j++) { 
        $TEXT->{$j+$f}{'c'} = '#';  
        $TEXT->{$j+$f}{'id'} = $id;
      }
      $TextLength += $t;
      $f+=$t-1;
    }
    if($t < 0) {
      for(my $j=$f; $j<$TextLength+$t; $j++) { $TEXT->{$j} = $TEXT->{$j-$t}; $TEXT->{$j-$t}={}}
      $TextLength += $t;
    }

    printf STDERR "Key  TEXT:\t";
    foreach my $m (sort {$a <=> $b} keys %{$TEXT}) {
        if($m <= $f-10) {next;}
        if($m < 0) {next;}
        if($m >= $f+10) {last;}
        if($m >= $TextLength) {last;}
        if($m == $f) {printf STDERR "|";}
        printf STDERR "%s", $TEXT->{$m}{'c'};
        if($m == $f) {printf STDERR "|";}
      }
      printf STDERR "\n";
  }

####################################
#  foreach my $f (sort {$a <=> $b} keys %{$TEXT}) { printf STDERR "TEXT:\t cur:$f\tid:$TEXT->{$f}{'id'} $TEXT->{$f}{'c'}\n";}

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

  my $id=-1; 

  ## loop through keystrokes from end to start
  foreach $k (sort {$b <=> $a} keys %{$KEY}) {
    $c = $KEY->{$k}{'c'};

    ## Assign Word ID to FIX samples in target window between time $f and time $k
    while($f <= $#{$F} && $F->[$f] > $k) {
      if($FIX->{$F->[$f]}{'w'} != 2) { $f++; next;}

      my $cur = $FIX->{$F->[$f]}{'c'}; # cursor
      if($cur >= $TextLength) {
        if($Verbose) { printf STDERR "Target FIX at time:$F->[$f] cur:$FIX->{$F->[$f]}{'c'} >= TEXT:$TextLength\n"; }
        $cur = $TextLength-1;
      }
      if($cur < 0) { $cur = 0;}
      if(!defined($TEXT->{$cur}{'id'})) { printf STDERR "Fix time $k Undef id in TEXT cur:$cur len:$TextLength\n"; }

      ## This is the target ==> source mapping
      $FIX->{$F->[$f]}{'tid'} = $TEXT->{$cur}{'id'}; 
      $f++; 
    }

    ## Assign Word ID to EYE samples in target window between time $e and time $k
    while($e <= $#{$E} && $E->[$e] > $k) {
      my $e1 = $E->[$e];
      if($EYE->{$E->[$e]}{'w'} == 2) {
        my $cur = $EYE->{$E->[$e]}{'c'};

        if($cur >= $TextLength) {
          if($Verbose) {printf STDERR "Target EYE at time:$e1 cur:$EYE->{$e1}{'c'} >= TEXT:$TextLength\n"; }
 	  $cur = $TextLength-1;
        }
        if($cur < 0) { $cur = 0;}
        if(!defined($TEXT->{$cur}{'id'})) { printf STDERR "Eye time $k Undef id in TEXT cur:$cur len:$TextLength\n"; }

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

      if($KEY->{$k}{'k'} ne $TEXT->{$c}{'c'} && $TEXT->{$c}{'c'} ne '#') {
        printf STDERR "MapTarget no match time:$k cursor:$c key>%s<\ttext:>%s<\n", $KEY->{$k}{'k'}, $TEXT->{$c}{'c'}; 
        foreach my $m (sort {$a <=> $b} keys %{$TEXT}) {
          if($m <= $c-10) {next;}
          if($m < 0) {next;}
          if($m >= $c+10) {last;}
          if($m >= $TextLength) {last;}
          if($m == $c) {print STDERR "|";}
          print STDERR "$TEXT->{$m}{'c'}";
          if($m == $c) {print STDERR "|";}
        }
        printf STDERR "\n";
      }

# remember last id for deletions
      $id = $KEY->{$k}{'id'} = $TEXT->{$c}{'id'};
#print STDERR "Mapping: $k $c $id\n";
      for($j=$c; $j<$TextLength; $j++) { $TEXT->{$j} = $TEXT->{$j+1}; $TEXT->{$j+1}={};}
      $TextLength--;

    }

    elsif($KEY->{$k}{'t'} eq "del") {


## delete the only char in TEXT
      if($TextLength <= 0) { }
## delete last char in TEXT
      elsif(!defined($TEXT->{$c}) || !defined($TEXT->{$c}{id})) {
        if(defined($TEXT->{$c-1}) && defined($TEXT->{$c-1}{id})) { $id = $TEXT->{$c-1}{'id'}; }
        else { printf STDERR "MapTarget1 time $k undefined id: cur:%s/$TextLength %s\n", $c-1, $KEY->{$k}{'k'}; }
      }
## delete first char in TEXT
      elsif(!defined($TEXT->{$c-1}) || !defined($TEXT->{$c-1}{id})) {
        if(defined($TEXT->{$c}) && defined($TEXT->{$c}{id})) { $id = $TEXT->{$c}{'id'}; }
        else { printf STDERR "MapTarget2 time $k undefined id: cur:%s/$TextLength %s\n", $c, $KEY->{$k}{'k'};}
      }
## deletion in the middle of a word
      elsif($TEXT->{$c-1}{'id'} == $TEXT->{$c}{'id'}) { $id = $TEXT->{$c}{'id'}; }
## delete between two words: assume it's the from the suffix
      else { $id = $TEXT->{$c-1}{'id'}; }

      for($j=$TextLength; $j>$c; $j--) { $TEXT->{$j} = $TEXT->{$j-1};$TEXT->{$j-1}= {};}
      $KEY->{$k}{'id'}=$TEXT->{$c}{'id'} = $id;
      $TEXT->{$c}{'c'} = $KEY->{$k}{'k'};

      $TextLength++;
    }
    else { printf STDERR "ERROR undefined KEYSTROKE:\n"; d($KEY->{$k}); }

###
#printf STDERR "MapTarget2 $k $KEY->{$k}{'t'} cur:$c id:$id $KEY->{$k}{'k'} len:$TextLength\t";
#        foreach my $m (sort {$a <=> $b} keys %{$TEXT}) {
#          if($m <= $c-10) {next;}
#          if($m < 0) {next;}
#          if($m >= $c+10) {last;}
#          if($m >= $TextLength) {last;}
#          if($m == $c) {print STDERR "|";}
#          print STDERR "$TEXT->{$m}{'c'}";
#          if($m == $c) {print STDERR "|";}
#        }
#        printf STDERR "\n";
###
  }

### fixations after end of typing
  while($f <= $#{$F}) {
    if($FIX->{$F->[$f]}{'w'} == 2) {
      my $cur = $FIX->{$F->[$f]}{'c'}; 
      $FIX->{$F->[$f]}{'tid'} = $TEXT->{$cur}{'id'}; 
    }
    $f++;
  }

### gaze samples after end of typing
  while($e <= $#{$E}) {
    if($EYE->{$E->[$e]}{'w'} == 2) {
      my $cur = $EYE->{$E->[$e]}{'c'};
      $EYE->{$E->[$e]}{'tid'} = $TEXT->{$cur}{'id'}; 
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
      print STDERR "CheckBackward CHR: $k $CHR->{tra}{$k}\n"; 
      next;
    }
    if($CHR->{tra}{$k}{'c'} ne $TEXT->{$k}{'c'}) {
      print STDERR "CheckBackward CHR: $k $TEXT->{$k}{'c'}, $CHR->{tra}{$k}{'c'}\n"; 
      next;
    }
  }
}

################################################
#  PRINTING
################################################

my $FIXATIONS = {};
my $fixations =0;

my $MODIFICATIONS = {};
my $modifications =0;

sub FixModTable {
  my ($segID) = @_;

  my ($m, $ord);

  my $seg = $ID2Seg->{$segID}{3};
  foreach my $t (sort {$a<=>$b} keys %{$FIX}) {

    if(!defined($FIX->{$t}{sid}) && !defined($FIX->{$t}{tid})) { next; }

    if($FIX->{$t}{w} == 1) {
      $FIX->{$t}{tid} = '';
      my $id=$FIX->{$t}{'sid'};
      if(defined($ALN->{'sid'}) && defined($ALN->{'sid'}{$id})) { 
        my $k = 0;
        foreach my $sid (sort  {$a <=> $b} keys %{$ALN->{'sid'}{$id}{'tid'}}) {
          if($k >0) {$FIX->{$t}{tid} .= "+";}
          $FIX->{$t}{tid} .= $sid;
          $k++;
        }
      }  
    }
    elsif ($FIX->{$t}{w} == 2) {
      $FIX->{$t}{sid} = '';
      my $id=$FIX->{$t}{'tid'};
      if(defined($ALN->{'tid'}) && defined($ALN->{'tid'}{$id})) {  
        my $k = 0;
        foreach my $sid (sort  {$a <=> $b} keys %{$ALN->{'tid'}{$id}{'sid'}}) {
          if($k >0) {$FIX->{$t}{sid} .= "+";}
          $FIX->{$t}{sid} .= $sid;
          $k++;
        }
      }
    } 
    else {next;}

    $FIXATIONS->{$fixations++} = "    <Fix time=\"$t\" win=\"$FIX->{$t}{w}\" cur=\"$FIX->{$t}{c}\" dur=\"$FIX->{$t}{d}\" seg=\"$seg\" sid=\"$FIX->{$t}{sid}\" tid=\"$FIX->{$t}{tid}\" />\n";
  }

  foreach my $t (sort {$a<=>$b} keys %{$KEY}) {
#    print STDERR "PrintKEY $t\n";
#    d($KEY->{$t});
#    print STDERR "PrintAlign $KEY->{$t}{id}\n";
#    d($ALN->{'tid'}{$KEY->{$t}{id}});

    if(!defined($KEY->{$t}{id})) { 
      print STDERR "KEY Undefined $t\n";
      d($KEY->{$t});
      next;
    }

    my $s = '';
    if(defined($ALN->{'tid'}) && defined($ALN->{'tid'}{$KEY->{$t}{'id'}})) { 
      my $k = 0;
      foreach my $sid (sort  {$a <=> $b} keys %{$ALN->{'tid'}{$KEY->{$t}{'id'}}{'sid'}}) {
        if($k >0) {$s .= "+";}
        $s .= $sid;
        $k++;
      }
    }
    my $chr = MSescape($KEY->{$t}{k});
    $MODIFICATIONS->{$modifications++} = "    <Mod time=\"$t\" type=\"$KEY->{$t}{t}\" cur=\"$KEY->{$t}{c}\" chr=\"$chr\" seg=\"$seg\" sid=\"$s\" tid=\"$KEY->{$t}{id}\" />\n";
#    print STDERR "    <Mod time=\"$t\" type=\"$KEY->{$t}{t}\" cur=\"$KEY->{$t}{c}\" chr=\"$chr\" seg=\"$seg\" sid=\"$s\" tid=\"$KEY->{$t}{id}\" />\n";
  }
}

sub PrintTranslog{
  my ($fn) = @_;
  my $m;

  open(FILE, '>:encoding(utf8)', $fn) || die ("cannot open file $fn");

  foreach my $k (sort {$a<=>$b} keys %{$TRANSLOG}) { 
    if($TRANSLOG->{$k} =~ /<\/LogFile>/) {last; }
    print FILE "$TRANSLOG->{$k}"; 
  }


  print FILE "  <Fixations>\n";
  foreach my $k (sort {$a<=>$b} keys %{$FIXATIONS}) { print FILE "$FIXATIONS->{$k}"; }
  print FILE "  </Fixations>\n  <Modifications>\n";
  foreach my $k (sort {$a<=>$b} keys %{$MODIFICATIONS}) { print FILE "$MODIFICATIONS->{$k}"; }
  print FILE "  </Modifications>\n<\/LogFile>\n";
  close(FILE);
}

