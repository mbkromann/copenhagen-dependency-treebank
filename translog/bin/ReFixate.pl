#!/usr/bin/perl -w

use strict;
use open IN  => ":crlf";
use Encode qw(encode decode);
use IO::Handle;
use File::Copy;
use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

#binmode STDIN, ":utf8";
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

# Escape characters 
my $map = { map { $_ => 1 } split( //o, "\\<> \t\n\r\f\"" ) };

my $minFixDur  = 45;
my $maxFixGap  = 50;
my $FixWidth = 100;
my $FixUnitBoundary = 400;
my $ForwardCurDistance = 20;
my $BackwardCurDistance = 100;
my $eyeFixation = 3;
my $FixationAlgo = 0;

my $usage =
  "Read Translog-II file and write output to STDOUT\n".
  "  -C <T2_file>  Check translog events\n".
  "  -F <T2_file>  Re-compute fixations\n".
  "  -M <T2_file>  Re-compute fixation mappings \n".
  "  -U <T2_file>  Re-compute fixation units \n".
  "  -D <T2_file>  Detect Fixation Parameters\n".
  "  -Q <T2_file>  Measure fixation quality \n".
  "  -K <T2_file>  Re-order Key events\n".
  "  -S <T2_file>  Compute distance of successive eye-samples\n".
  "  -W <STDIN>  set Win=\"-1\"\n".
  "Options for Fixation re-computation (-F):\n".
  "  -w Max. fixation diameter  [$FixWidth]\n".
  "  -g Max. sample gap within fixation  [$maxFixGap]\n".
  "  -d Min. fixation duration [$minFixDur]\n".
  "  -e eye 1:left 2:right 3:both [$eyeFixation]\n".
  "  -s Fixation geometric:0  arithmatic:1 $FixationAlgo]\n".
  "Options for Fixation mapping (-M):\n".
  "  -u Max. timelapse for fixation unit boundary [$FixUnitBoundary]\n".
  "  -f Max. forward cursor saccade  [$ForwardCurDistance]\n".
  "  -b Max. backward cursoe saccade [$BackwardCurDistance]\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_s $opt_e $opt_w $opt_g $opt_d $opt_u $opt_f $opt_b $opt_W $opt_U $opt_K $opt_S $opt_Q $opt_F $opt_M $opt_C $opt_O $opt_D $opt_v $opt_h);

use Getopt::Std;
getopts ('U:M:Q:C:F:S:D:K:Wu:e:s:w:g:d:f:b:v:h');

die $usage if defined($opt_h);

### Recompute fixations
if (defined($opt_s)) { $FixationAlgo = $opt_s;}
if (defined($opt_e)) { $eyeFixation = $opt_e;}
if (defined($opt_w)) { $FixWidth = $opt_w;}
if (defined($opt_d)) { $minFixDur = $opt_d;}
if (defined($opt_g)) { $maxFixGap = $opt_g;}
if (defined($opt_u)) { $FixUnitBoundary = $opt_u;}
if (defined($opt_f)) { $ForwardCurDistance = $opt_f;}
if (defined($opt_b)) { $BackwardCurDistance = $opt_b;}

if (defined($opt_D)) { DetectFixPara($opt_D); exit;}
if (defined($opt_C)) { CheckTranslog($opt_C); exit;}
if (defined($opt_F)) { RecompFixation($opt_F); exit;}
if (defined($opt_M)) { RecompMappings($opt_M); exit;}
if (defined($opt_U)) { RecompFixUnits($opt_U); exit;}
if (defined($opt_Q)) { FixesQuality($opt_Q); exit;}
if (defined($opt_K)) { ReOrderKey($opt_K); exit;}
if (defined($opt_S)) { SampleDist($opt_S); exit;}
if (defined($opt_W)) { SetWinMinusOne(); exit;}

printf STDERR "No Output produced\n";
die $usage;

exit;

sub NFileNames{
  our ($func, $fn) = @_;

  my $F = [split(/\s+/, $fn)];
  for(my $i=0;$i<=$#{$F};$i++) { &{$func}($F->[$i]);}
}

##########################################################
# Check Translog File
##########################################################
# duplicates
# successive time stamps
# fixationnstart and fixation end

sub CheckTranslog {
  my ($fn) = @_;

  my ($first, $last, $N, $Dur, $dur, $dur1, $block, $fix, $s, $x, $y);
  my ($n, $tt, $time, $kt, $FT, $cur, $Cur, $eye, $event);
  my $fixLength =0;
  my $dist = 0; 
  my $FIX = {};
  my $Time = {};
  my $TT = {};

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  printf STDERR "Reading: $fn\n";

  $kt=$event=$n=$dur1=$fix=$Dur=0;
  $FIX->{'dup'}=$FIX->{'time'}=$FIX->{'del'}=$FIX->{'dur'}=$FIX->{'end'}=$FIX->{'unequal'}=0;
  while(defined($_ = <FILE>)) {
#printf STDERR "$_";

    if(/<Events>/) {$event = -1; }
    if(/<\/Events>/) {$event =0; }

    if($event <= 0) {
      $FIX->{'n'}{$n} = $_;
      $n+=10;
      if($event == -1) {$event =1;}
      next;
    }

    # Duplicates 
    if(/<Fix/ || /<Eye/) {
      $s = $_;
      $s =~ s/Time="([0-9][0-9]*)"//;
      if(defined($FIX->{'D'}{$s})){
        printf STDERR "Duplicate data entry:$_";
        $FIX->{'dup'} ++;
        next;
      }
      $FIX->{'D'}{$s}++;
    }

    if(/Time="([0-9][0-9]*)"/) { $time = $1;}
    else {printf STDERR "No Time in Event:$_";}

    # Time identical
    if(defined($FIX->{'T'}{$time})){
      while(defined($Time->{$time}))  { $time ++;}
      s/Time="([0-9][0-9]*)"/Time="$time"/;
      printf STDERR "Identical Translog time: $time\n";
      $FIX->{'time'} ++;
    }
    $FIX->{'T'}{$time} = $n;

    if(/TT="([0-9][0-9]*)"/)  {
      if(defined($TT->{$1})) { 
        printf STDERR "Identical Tracker time: $tt\n";
      }
      $FIX ->{'TT'}{$1} ++;
    }

    if($event == 1 && /<Key/) {
      if(/Type="delete"/ && ! /Text=/) { 
        printf STDERR "Inserted deleted text: $time\n";
        $_ =~ s/Value="/Text="_" Value="/;
      }
    }

    if($event == 1 && /<Fix/) {
      $block=$dur=$cur=0;
      if(/Cursor="([0-9][0-9]*)"/) {$cur = $1; }
      if(/Block="([0-9][0-9]*)"/) {$block = $1; }
      if(/Dur="([0-9][0-9]*)"/) {$dur = $1; }
      if(/TT="([0-9][0-9]*)"/) {$tt = $1; }
      
## End of fixation
      if($block == 0 && $dur == 0) { 
        if($cur != $Cur) { 
          printf STDERR "Fixation end unmatched Cursor ($Cur/$cur):$_"; 
          $FIX->{'cur'} ++;
          next;
        }
        if($fix == 0) { 
          printf STDERR "Fixation End with no start:$_"; 
          $FIX->{'end'} ++;
          next;
        }
        $fix = 0; 
        $dur1 = $tt - $first -1;
        if($dur1 < 80 && $Dur < 80) {  
          printf STDERR "Delete fixation:$FIX->{'n'}{$N}";
          $FIX->{'del'} ++;
	  delete($FIX->{'n'}{$N});
	  next;
        }
        elsif($Dur == 0) { 
          $FIX->{'n'}{$N} =~ s/Text="/Dur="$dur1" Text="/;
          $FIX->{'dur'} ++;
#          printf STDERR "Added duration in fixation start\n$FIX->{$N}"; 
	  $Dur = $dur1;
        }
        elsif($Dur - $dur1 > 100 || $dur1 - $Dur > 100) { 
          printf STDERR "Fixation duration time $first $tt: $dur1 and $Dur\n"; 
          $FIX->{'unequal'} ++;
        }
      }
#printf STDERR "Fixation $fix end $tt and $time\n"; 
## Start of fixation
      else {
        ## no end of previous fixation
        if($fix == 1) { 
          $dur1 = $tt - $first -1;
          if($dur1 < 80) {  
            printf STDERR "Delete fixation:$FIX->{'n'}{$N}";
            $FIX->{'dur'} ++;
	    delete($FIX->{'n'}{$N});
	    $fix =0;
          }
	  else {  
            $s = $FIX->{'n'}{$N};
            printf STDERR "Added fixation end:$_"; 
            if(/X="([0-9][0-9]*)"/)  {$x = $1; }
            if(/Y="([0-9][0-9]*)"/)  {$y = $1; }
            my $t1 = $time-1; 
	    my $t2 = $tt-1;
            $FIX->{'n'}{$n-1} = "<Fix Time=\"$t1\" TT=\"$t2\" X=\"$x\" Y=\"$y\" />\n";
            $FIX->{'end'} ++;
	    $fix =1;
          }
        }
        else { $fix = 1; }
        $first = $tt;
        $Cur =$cur;
        $N =$n;
        $Dur =$dur;
      }
    }
    $FIX->{'n'}{$n} = $_;
    $n+=10;
  }
  printf STDERR "Duplicate Entry:$FIX->{'dup'}\nIdentical Translog Time:$FIX->{'time'}\nFixation deleted:$FIX->{'del'}\nFixation duration added:$FIX->{'dur'}\nFixation end added:$FIX->{'end'}\nUnequal fixation duration:$FIX->{'unequal'}\n";
  foreach $n (sort {$a <=> $b} keys %{$FIX->{'n'}}) { print STDOUT "$FIX->{'n'}{$n}"; }
}

sub SetWinMinusOne {
  my $event = 0;

  while(defined($_ = <>)) {
    if(/<Events>/) {$event =1; }

    if($event == 1 && /Win=/) { s/Win="[^"]*"/Win="-1"/;}
    print STDOUT "$_";
    if(/<\/Events>/) {$event =0; }
} }

##########################################################
# Measure Fixation Quality
##########################################################

sub ReOrderKey {
  my ($fn) = @_;

  my ($time, $cur, $cur1, $n, $N, $m, $M);
  my $FIX = {};

  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  printf STDERR "Reading: $fn\n";

  my $event = 0;
  my $type = '';
  $n = 0;

  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Events>/) {$event =1; }
    if(/<\/Events>/) {$event =0; }

    if($event == 1 && /<Key/) {
      if(/Cursor="([0-9][0-9]*)"/) {$cur = $1; }
      if(/Time="([0-9][0-9]*)"/)  {$time = $1; }
      if(/Type="([^"]*)"/)  {$type = $1; }

      $FIX->{'t'}{$time}{'n'}++;
      $FIX->{'t'}{$time}{'c'}{$n}{'n'}=$cur;
      $FIX->{'t'}{$time}{'c'}{$n}{'t'}=$type;
    }
    $FIX->{'n'}{$n} = $_;
    $n+=10;
  }
  foreach $time (sort {$a <=> $b} keys %{$FIX->{'t'}}) { 
    if($FIX->{'t'}{$time}{'n'} > 1) {
#printf STDERR "=== \n";
      foreach $n (sort {$a <=> $b} keys %{$FIX->{'t'}{$time}{'c'}}) { 
        my $i = $n;
	$cur = $FIX->{'t'}{$time}{'c'}{$n}{'n'};
#printf STDERR "XXX $time $n $cur\n";
        foreach $m (sort {$a <=> $b} keys %{$FIX->{'t'}{$time}{'c'}}) {
          if($m <= $n) {next;}
	  $cur1 = $FIX->{'t'}{$time}{'c'}{$m}{'n'};
          if($cur1 > $cur) {next;}
#          if($cur1 < $cur) {$cur = $cur1; $i=$m;}
#          if($FIX->{'t'}{$time}{'c'}{$m}{'n'} < $cur) {$cur = $FIX->{'t'}{$time}{'c'}{$m}{'n'}; $i=$m;}
printf STDERR "--> $time  $FIX->{'t'}{$time}{'c'}{$n}{'t'} $n $cur\t$FIX->{'t'}{$time}{'c'}{$m}{'t'} $m $cur1\n";
        }
        if($i != $n) { 
          $N = $FIX->{'n'}{$n};
          $M = $FIX->{'n'}{$i};
          $FIX->{'n'}{$n} = $M;
          $FIX->{'n'}{$i} = $N;
printf STDERR "$fn Changed Order $time $M\t$N\n";
        }
      }
    }
  }
  foreach $n (sort {$a <=> $b} keys %{$FIX->{'n'}}) { print STDOUT "$FIX->{'n'}{$n}"; }
}

##########################################################
# Measure Fixation Quality
##########################################################

sub FixesQuality {
  my ($fn) = @_;

  my ($tt, $tt1, $win, $win1, $cur, $cur1, $block, $block1, $dur, $dur1);
  my $FIX = {};

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  printf STDERR "Reading: $fn\n";

  my $event = 0;
  my $fix = 0;
  my $first = 0;
  my $last = 0;

  $tt = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Events>/) {$event =1; }
    if(/<\/Events>/) {$event =0; }

    if($event == 1 && /<Fix/) {
      $win1 = $cur1 = $block1 = $dur1 = 0;
      if(/Win="([0-9][0-9]*)"/) {$win =$1;}
      if(/Cursor="([0-9][0-9]*)"/) {$cur1 = $1; }
      if(/Block="([0-9][0-9]*)"/)  {$block1 = $1; }
      if(/Dur="([0-9][0-9]*)"/)  {$dur1 = $1; }
      if(/TT="([0-9][0-9]*)"/)  {$tt1 = $1; }
      
## End of fixation
      if($first == 0 ) { $first = $tt;}
      $last = $tt;

      if($block1 == 0 && $dur1 == 0) { 
        if($fix == 0) { printf STDERR "No fixation start $tt1 and $tt\n"; next;}
        if($dur == 0) { $dur = $tt1 -$tt -1;}
#printf STDERR "Fixation $fix end $tt and $tt1\n"; 
	$FIX->{'fn'}++;
	$FIX->{'fd'}+=$dur;
        $FIX->{'fx'}{$dur} ++;
        $FIX->{'fw'}{$win}{'fn'}++;
        $FIX->{'fw'}{$win}{'fd'}+=$dur;
        $FIX->{'fw'}{$win}{'fx'}{$dur} ++;
	$fix = 0;
      }
## End of fixation
      else { 
#printf STDERR "Fixation $fix end $tt and $tt1\n"; 
        if($fix == 1) { 
          printf STDERR "No fixation end $tt1 and $tt\n"; 
          if($dur == 0) { $dur = $tt1 -$tt -1;}
	  $FIX->{'fn'}++;
	  $FIX->{'fd'}+=$dur;
	  $FIX->{'fx'}{$dur}++;
          $FIX->{'fw'}{$win}{'fn'}++;
          $FIX->{'fw'}{$win}{'fd'}+=$dur;
          $FIX->{'fw'}{$win}{'fx'}{$dur}++;
        }
        $fix = 1;
      }
      $win = $win1;  $cur = $cur1; $block = $block1; $dur = $dur1;
      $tt = $tt1;
    }
    if($event == 1 && /<Eye/) {
      if(/Win="([0-9][0-9]*)"/) {$win =$1;}
      if($win != 0 || $fix == 1) {$FIX->{'ev'} ++;}
      $FIX->{'en'} ++;
      $FIX->{'ew'}{$win} ++;
      if($fix == 1) { $FIX->{'ef'} ++;}
    }
  }
  $dur = $last - $first;
  printf STDERR "Fixations\tNb:%d\tFixDur:%d\tAvDur:%4.4f\tTraDur:%d\n", 
                $FIX->{'fn'}, $FIX->{'fd'}, $FIX->{'fd'}/$FIX->{'fn'}, $dur; 
  foreach $win (sort {$a <=> $b} keys %{$FIX->{'fw'}}) {
    printf STDERR "Window:$win\tNb:%d\tPercent:%4.4f\tAvDur:%4.4f\n", 
           $FIX->{'fw'}{$win}{'fn'}, 
           100*$FIX->{'fw'}{$win}{'fd'}/$dur, 
           $FIX->{'fw'}{$win}{'fd'}/$FIX->{'fw'}{$win}{'fn'}; 
  }
  printf STDERR "EyeSample Nb:%d\tInFix:%d\tPer:%4.4f\tPer(w1+2):%4.4f\n", 
     $FIX->{'en'}, $FIX->{'ef'}, 
     100*$FIX->{'ef'}/$FIX->{'en'},
     100*$FIX->{'ef'}/$FIX->{'ev'}; 
  foreach $win (sort {$a <=> $b} keys %{$FIX->{'ew'}}) {
    printf STDERR "Window $win\tNb:%d\tPercent:%4.4f\n", 
           $FIX->{'ew'}{$win}, 
           100*$FIX->{'ew'}{$win}/$FIX->{'en'}; 
  }
  printf STDERR "\n";

}

##########################################################
# Recompute Fixation Insert <Fix ... /> tags
##########################################################

sub RecompFixation {
  my ($fn) = @_;

  my ($win, $win1, $xl, $xr, $xm, $xf, $yl, $yr, $ym, $yf) = 0;
  my ($xm1, $ym1);
  my ($m, $tt, $tt1, $tm, $tf, $tf1, $FT, $cur, $eye, $event);
  my ($FF, $FH, $FL);
  my $fixLength =0;
  my $dist = 0; 
  my $N = {};
  my $n = 0;

#  open(FILE, $fn) || die ("cannot open file $fn");
  if($fn ne '-') { 
    open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
    STDIN->fdopen(\*FILE,  'r') or die $!;
  }
  printf STDERR "Reading: $fn\n";

  $event = 0;
  $tf1=$tt1=0;
  $win=0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Events>/) {$event =1; }
    if(/<\/Events>/) {$event =0; }

    if($event == 1 && /<Fix/) {next;}
    if(/Win="([0-9][0-9]*)"/) {$win =$1;}

    if($win > 0 && $event == 1 && /<Eye/) {

      $eye = 0;
      if(/Xl="([^"]*)"/)  {$xl = $1; $eye = 1;}
      if(/Yl="([^"]*)"/)  {$yl = $1; }
      if(/Xr="([^"]*)"/)  {$xr = $1; $eye += 2;}
      if(/Yr="([^"]*)"/)  {$yr = $1; }
      if(/TT="([^"]*)"/)  {$tt = $1; }
      if(/Time="([^"]*)"/) {$tm = $1;}
      if(/Cursor="([^"]*)"/){$cur->{$1} ++;}

      if($tt == $tt1) {
        printf STDERR "Identical Tracker time $tt: run -C $fn\n";
        next;
      }

#printf STDERR "$_";
      ## xm/ym: center of eyes
      if($eyeFixation == 3 && $eye == 3) { $xm = ($xl + $xr)/2; $ym = ($yl + $yr)/2;}
      elsif($eyeFixation & 1 && $eye & 1) { $xm = $xl; $ym = $yl;}
      elsif($eyeFixation & 2 && $eye & 2) { $xm = $xr; $ym = $yr;}
      else { printf STDERR "ERROR1: no eyes $eye $_\n"; next;}

#printf STDERR "AAA1 Len:$fixLength td:%d x:$xm y:$ym\n",  $tt -$tt1;
      ## initialise fixation
      if($fixLength == 0) {
        $xf = $xm; 
	$yf = $ym; 
        $tf = $tm; 
        $FT = $tt; 
        $FF = $n; 
        $fixLength =1;
      }
      else {
        if($FixationAlgo == 0) {
          my $dist2 = (($xf/$fixLength) - $xm) * (($yf / $fixLength) - $ym);
          if($dist2 < 0) {$dist2 *= -1;}
          $dist = sqrt($dist2);
        }
        elsif($FixationAlgo == 1) {
          if($xm1>$xm) {$dist = $xm1 - $xm;} else{$dist=$xm - $xm1;}
          if($ym1>$ym) {$dist += $ym1 - $ym;} else{$dist+=$ym - $ym1;}
          $dist /= 2;
        }

        ## sample in fixation
        if($dist < $FixWidth && $tt -$tt1 < $maxFixGap) {
          $xf += $xm; 
          $yf += $ym; 
          $fixLength ++;
        }
        ## fixation end
        elsif($tt1 - $FT > $minFixDur) {
	#Start of fixation 
          $m = $FF -1;
	  my $x = int($xf / $fixLength); 
	  my $y = int($yf / $fixLength); 
          my $cur1 = -1;
          foreach my $n (keys %{$cur}) { 
            if( $cur1 == -1) {$cur1 = $n} elsif($cur->{$n} > $cur->{$cur1}) {$cur1 = $n;}
          }

	  $N->{$m}=sprintf("\t<Fix Time=\"%s\" TT=\"%s\" Win=\"$win\" Dur=\"%s\" Cursor=\"$cur1\" Block=\"3\" X=\"$x\" Y=\"$y\" \/>\n", $tf-1,  $tt-1,  $tt1-$FT); 
	#End of fixation 
          $m = $FL+1;
	  $N->{$m} = sprintf("\t<Fix Time=\"%s\" TT=\"%s\" Win=\"$win\" Cursor=\"$cur1\" X=\"$x\" Y=\"$y\" \/>\n", $tf1+1, $tt1+1);
          $xf = $xm; 
	  $yf = $ym; 
          $tf = $tm; 
          $FT = $tt; 
          $FF = $n;
          $cur = {};
          $fixLength =1;
        }
	else {
          $xf = $xm; 
	  $yf = $ym; 
          $tf = $tm; 
          $FT = $tt; 
          $FF = $n;
          $fixLength =1;
        }
      }
      $win1 = $win;
      $FL = $n; 
      $tt1 = $tt;
      $tf1 = $tm;

      $xm1 = $xm;
      $ym1 = $ym;
    }

    $N->{$n} = $_;
    $n+=5;
  }
  close (FILE);

  foreach $n (sort {$a <=> $b} keys %{$N}) { print STDOUT "$N->{$n}"; }

  return $N;
}


##########################################################
# Recompute Mappings from GazeData
##########################################################

sub RecompGazeMapping {
  my ($fn) = @_;

  my ($win, $win1, $xl, $xr, $xm, $xf, $yl, $yr, $ym, $yf);
  my ($xm1, $ym1);
  my ($m, $tt, $tt1, $tm, $tf, $tf1, $FT, $cur, $eye, $event);
  my ($TXT, $X, $Y, $FF, $FH, $FL);
  my $fixLength =0;
  my $dist = 0; 
  my $N = {};
  my $n = 0;

#  open(FILE, $fn) || die ("cannot open file $fn");
  if($fn ne '-') { 
    open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
    STDIN->fdopen(\*FILE,  'r') or die $!;
  }
  printf STDERR "Reading: $fn\n";

  $event = 0;
  $tf1=$tt1=0;
  $win=0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Events>/) {$event =1; }
    if(/<\/Events>/) {$event =0; }
    if(/<SourceTextChar>/) {$event =2; }
    if(/<\/SourceTextChar>/) {$event =0; }

    if($event == 2 && /<CharPos/) {
      my ($x, $y, $w, $h, $c, $v);
      if(/X="([0-9][0-9]*)"/)  {$x = $1; $eye = 1;}
      if(/Y="([0-9][0-9]*)"/)  {$y = $1; }
      if(/Width="([0-9][0-9]*)"/) {$w = $1; $eye += 2;}
      if(/Height="([0-9][0-9]*)"/)  {$h = $1; }
      if(/Cursor="([^"]*)"/)  {$c = $1; }
      if(/Value="([^"]*)"/)  {$v = $1; }

      $TXT->{$Y}{$X}{'c'}= $c;
      $TXT->{$Y}{$X}{'v'}= $y;
    }
    if($event == 1 && /<Fix/) {next;}
    if(/Win="([0-9][0-9]*)"/) {$win =$1;}

    if($win > 0 && $event == 1 && /<Eye/) {

      $eye = 0;
#      if(/Win="([0-9][0-9]*)"/) {$win =$1;}
      if(/Xl="([0-9][0-9]*)"/)  {$xl = $1; $eye = 1;}
      if(/Yl="([0-9][0-9]*)"/)  {$yl = $1; }
      if(/Xr="([0-9][0-9]*)"/)  {$xr = $1; $eye += 2;}
      if(/Yr="([0-9][0-9]*)"/)  {$yr = $1; }
      if(/TT="([0-9][0-9]*)"/)  {$tt = $1; }
      if(/Time="([0-9][0-9]*)"/) {$tm = $1;}
      if(/Cursor="([0-9][0-9]*)"/){$cur = $1;}

      if($tt == $tt1) {
        printf STDERR "Identical Tracker time $tt: run -C $fn\n";
        next;
      }

#printf STDERR "$_";
      ## xm/ym: center of eyes
      if($eyeFixation == 3 && $eye == 3) { $xm = ($xl + $xr)/2; $ym = ($yl + $yr)/2;}
      elsif($eyeFixation & 1 && $eye & 1) { $xm = $xl; $ym = $yl;}
      elsif($eyeFixation & 2 && $eye & 2) { $xm = $xr; $ym = $yr;}
      else { printf STDERR "ERROR1:$eye $_\n"; next;}

#printf STDERR "AAA1 Len:$fixLength td:%d x:$xm y:$ym\n",  $tt -$tt1;
      ## initialise fixation
      if($fixLength == 0) {
        $xf = $xm; 
	$yf = $ym; 
        $tf = $tm; 
        $FT = $tt; 
        $FF = $n; 
        $fixLength =1;
      }
      else {
        if($FixationAlgo == 0) {
          $dist = sqrt(((($xf/$fixLength) - $xm) ** 2) + ((($yf / $fixLength) - $ym) ** 2));
          $dist = $dist * 100 / ($tt - $tt1);
        }
        elsif($FixationAlgo == 1) {
          if($xm1>$xm) {$dist = $xm1 - $xm;} else{$dist=$xm - $xm1;}
          if($ym1>$ym) {$dist += $ym1 - $ym;} else{$dist+=$ym - $ym1;}
#          $dist /= 2;
          $dist = $dist*200 / ($tt - $tt1);
        }

        ## sample in fixation
        if($dist < $FixWidth && $tt -$tt1 < $maxFixGap) {
          $xf += $xm; 
          $yf += $ym; 
          $fixLength ++;
        }
        ## fixation end
        elsif($tt1 - $FT > $minFixDur) {
	#Start of fixation 
          $m = $FF -1;
	  my $x = int($xf / $fixLength); 
	  my $y = int($yf / $fixLength); 

	  $N->{$m}=sprintf("\t<Fix Time=\"%s\" TT=\"%s\" Win=\"-2\" Dur=\"%s\" Block=\"3\" X=\"$x\" Y=\"$y\" \/>\n",
 $tf-1,  $tt-1,  $tt1-$FT); 
	#End of fixation 
          $m = $FL+1;
	  $N->{$m} = sprintf("\t<Fix Time=\"%s\" TT=\"%s\" Win=\"-2\" X=\"$x\" Y=\"$y\" \/>\n", $tf1+1, $tt1+1);
          $xf = $xm; 
	  $yf = $ym; 
          $tf = $tm; 
          $FT = $tt; 
          $FF = $n;
          $fixLength =1;
        }
	else {
          $xf = $xm; 
	  $yf = $ym; 
          $tf = $tm; 
          $FT = $tt; 
          $FF = $n;
          $fixLength =1;
        }
      }
      $win1 = $win;
      $FL = $n; 
      $tt1 = $tt;
      $tf1 = $tm;

      $xm1 = $xm;
      $ym1 = $ym;
    }

    $N->{$n} = $_;
    $n+=5;
  }
  close (FILE);

  foreach $n (sort {$a <=> $b} keys %{$N}) { print STDOUT "$N->{$n}"; }

  return $N;
}

##########################################################
# Recompute Mappings insert Win, Cursor, Unit
##########################################################

sub RecompMappings {
  my ($fn) = @_;

  my ($win, $tt, $n, $xl, $yl, $cur, $F, $fix, $fixN, $eye, $event);
  my $U = undef;
  my $Fix = {};
  my $Unit = {};
  my $D = {};
  my $u = 0;

  if($fn ne '-') { 
    open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
    STDIN->fdopen(\*FILE,'r') or die $!;
  }
  printf STDERR "Reading: $fn\n";

  $n = $event = $fix = 0;
  $fixN = 0;
  while(defined($_ = <STDIN>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Events>/) {$event =1; }
    if(/<\/Events>/) {$event =0; }

    if($event == 1 && /<Fix/) {
      if(/TT="([0-9][0-9]*)"/)  {$tt = $1; }

      ## Fixation End
      if($fix == 1) {
        if(/Dur="([0-9][0-9]*)"/)  {
          printf STDERR "ERROR: Double Fixation End:$_";
          next;
        }
#check whether $F is part of the next unit 
        if(FixUnitBoundary($U, $F)) {
printf STDERR "UnitBoundary $u $U->{'S'} $U->{'E'}\n";
#          s/Dur="/Unit=\"end\" Dur=\"/;
	  $Unit->{$u++} = $Fix;
	  $D->{$F->{'S'}} =~ s/X="/Unit=\"start\" X="/;
	  $D->{$U->{'E'}} =~ s/X="/Unit=\"end\" X="/;
	  $Fix = {};
	  $fixN = 0;
        }
	s/Win=\"[^"]*\"/Win=\"$F->{'w'}\"/;
	$D->{$F->{'S'}} =~ s/Win=\"[^"]*\"/Win=\"$F->{'w'}\" Cursor=\"$F->{'cur'}\"/;

	$F->{'e'} = $tt;
	$F->{'E'} = $n;
#printf STDERR "FFF 1 $n $F->{'S'}\n";
	$U = $F;
	$Fix->{$fixN} = $F;
	$fixN++;
	$fix = 0;
      }

      ## Fixation Start
      else {
        if(!/Dur="([0-9][0-9]*)"/)  {
          printf STDERR "ERROR: Double Fixation Start:$_";
          next;
        }
#printf STDERR "Fixation unit $u fixation $fixN\n";
	if($fixN == 0) { s/Dur="/Unit=\"start\" Dur=\"/;}
	$F = {};
	$F->{'s'} = $tt;
	$F->{'S'} = $n;
#printf STDERR "Sample $fixN time:$tt gap:%s\n", $tt - $fixE;
	$fix = 1;
      }
    }

    elsif($fix == 1 && /<Eye/) {
      ## Fixation End

      if(/Cursor="([0-9][0-9]*)"/){$cur = $1;}
      if(/Win="([0-9][0-9]*)"/){$win = $1;}
      if(/Xl="([0-9][0-9]*)"/){$xl = $1;}
      if(/Yl="([0-9][0-9]*)"/){$yl = $1;}

      if(!defined($F->{'cur'})){ 
        $F->{'num'}++;
        $F->{'cur'}{$cur} ++;
        $F->{'win'}{$cur} = $win;
        $F->{'xl'}{$cur} = $xl;
        $F->{'yl'}{$cur} = $yl;
      }
      else {
        $F->{'num'}++;
        $F->{'cur'}{$cur} ++;
        $F->{'win'}{$cur} = $win;
       }

#printf STDERR "Fixation $fixN: $_";
    }
    $D->{$n} = $_;
    $n++;
  }
  close (FILE);
  foreach $n (sort {$a <=> $b} keys %{$D}) { print STDOUT "$D->{$n}"; }
}

sub FixUnitBoundary  {
  my ($U, $Fix) = @_;
  my ($m, $n, $x, $f);

#printf STDERR "FixUnitBoundary1:\n";
#d($Fix);

  if(!defined($Fix)) { return 0;}
  $f=-1;
  $x=0;
  foreach $m (sort {$Fix->{'cur'}{$b} <=> $Fix->{'cur'}{$a}} keys %{$Fix->{'cur'}}) { 
    if($f == -1){
      $f = $m;
      $x = $Fix->{'cur'}{$m};
    }
    elsif(($m>$f && $m-2<=$f) || ($m<$f && $m+2 >= $f)) { 
      $x += $Fix->{'cur'}{$m};
    }
#printf STDERR "Fixation:$n center:$f cur:$m num:$Fix->{'cur'}{$m}/$x\n";
  }
  $Fix->{'cur'} = $f;
  $Fix->{'w'} = $Fix->{'win'}{$f};
  $Fix->{'X'} = $Fix->{'xl'}{$f};
  $Fix->{'Y'} = $Fix->{'yl'}{$f};

  if(!defined($U)) { return 0;}

#printf STDERR "FixUnitBoundary Unit:\n";
#d($U);
#printf STDERR "FixUnitBoundary Fix:\n";
#d($Fix);

  printf STDERR "Fixation start:$Fix->{'s'}\twin:$Fix->{'win'}{$f} ($U->{'win'}{$U->{'cur'}}) dist:%s cur:$f ($U->{'cur'}) conf:%4.2f num:$x total:$Fix->{'num'}\n", $Fix->{'s'} - $U->{'e'}, 100*$x/$Fix->{'num'};

  if($x < $Fix->{'num'}/2) {
    print STDERR "Scattered fixation:\n";
    d($Fix);
  }
  if($Fix->{'s'} - $U->{'e'} > $FixUnitBoundary) { return 1;}
  if($Fix->{'win'}{$f} != $U->{'win'}{$U->{'cur'}}) { return 1;}
  if($f-$U->{'cur'} > $ForwardCurDistance) {return 1;}
  if($f-$U->{'cur'} < $BackwardCurDistance) {return 1;}
  return 0;
} 

##########################################################
# Distance between successive gaze samples
##########################################################

sub SampleDist {
  my ($fn) = @_;

  my ($win, $win1, $xl, $xr, $xm, $xf, $yl, $yr, $ym, $yf);
  my ($tt, $tt1, $tm, $tf, $tf1, $FT, $cur, $eye, $event);
  my $dist = 0; 
  my $FIX = {};

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  printf STDERR "Reading: $fn\n";

  $event = 0;
  $tf1=$tt1=0;
  my $n =0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Events>/) {$event =1; }
    if(/<\/Events>/) {$event =0; }

    if($event == 1 && /<Eye/) {

      $eye = 0;
      if(/Win="([0-9][0-9]*)"/) {$win =$1;}
      if(/Xl="([0-9][0-9]*)"/)  {$xl = $1; $eye = 1;}
      if(/Yl="([0-9][0-9]*)"/)  {$yl = $1; }
      if(/Xr="([0-9][0-9]*)"/)  {$xr = $1; $eye += 2;}
      if(/Yr="([0-9][0-9]*)"/)  {$yr = $1; }
      if(/TT="([0-9][0-9]*)"/)  {$tt = $1; }
      if(/Time="([0-9][0-9]*)"/) {$tm = $1;}
      if(/Cursor="([0-9][0-9]*)"/){$cur = $1;}

      if($win == 0) {next;}

#printf STDERR "$_";
      if($eye == 1) { $xm = $xl; $ym = $yl;}
      elsif($eye == 2) { $xm = $xr; $ym = $yr;}
      elsif($eye == 3) { $xm = ($xl + $xr)/2; $ym = ($yl + $yr)/2;}
      else { printf STDERR "ERROR1:$eye $_\n"; next;}

#printf STDERR "AAA1 Len:$fixLength td:%d x:$xm y:$ym\n",  $tt -$tt1;
      ## initialise fixation
      if($n > 0) {
        $dist = sqrt((($xf - $xm) ** 2) + (($yf-$ym) ** 2));
	$FIX->{$dist} ++;
      }
      $xf = $xm; 
      $yf = $ym; 
      $n ++;
    }
  }
  foreach $n (sort {$a <=> $b} keys %{$FIX}) { print STDOUT "$FIX->{$n}\t$n\n"; }
}

