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
  "Tokenisation of Text file: \n".
  "  -X in:  Text file <filename>\n".
  "     out:   <filename>.token\n".
  "Tokenisation of Translog file: \n".
  "  -T in:  Translog XML file <filename>\n".
  "  -D out: Write <filename>.{src,tgt} output\n".
  "Tokenisation of Translog file (form Target tag): \n".
  "  -T in:  Translog XML file <filename>\n".
  "  -G out: Write <filename>.{src,tgt} output\n".
  "Produce ProgGraph files: \n".
  "  -T in:  Translog XML file <filename1>\n".
  "  -A in:  Alignment file <filename2>.{atag,src,tgt}\n".
  "  -O out: Write output   <filename3>.{kd,fd,fu,pu,st}\n".
  "Re-assign tokens in *atag file \n".
  "  -C in:  Check atag starting with 0 <filename.atag>\n".
  "  -R in:  Renumber atag +1 <filename.atag>\n".
  "Options:\n".
  "  -t starting token id [1] \n".
  "  -f fixation unit gap \n".
  "  -p production unit gap \n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_f $opt_p $opt_t $opt_G $opt_R $opt_C $opt_X $opt_O $opt_D $opt_T $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('C:R:X:T:A:D:O:G:f:p:v:t:h');

die $usage if defined($opt_h);

my $MaxFixGap = 400;
my $MaxKeyGap = 1000;
my $TokenNumber = 1;

my $ALN = undef;
my $FIX = undef;
my $EYE = undef;
my $PRB = undef;
my $KEY = undef;
my $SRC = undef;
my $TGT = undef;
my $TRA = undef;
my $TEXT = undef;
my $Verbose = 0;

## Key mapping
my $lastKeyTime = 0;
my $lastCursorPos = 0;
my $TextLength = 0;


if (defined($opt_v)) {$Verbose = $opt_v;}
if (defined($opt_f)) {$MaxFixGap = $opt_f;}
if (defined($opt_p)) {$MaxKeyGap = $opt_p;}
if (defined($opt_t)) {$TokenNumber = $opt_t;}

if(defined($opt_C)) {
  CheckATAGNumbers($opt_C);
  exit;
}

if(defined($opt_R)) {
  ReNumberATAG($opt_R, 1);
  exit;
}

if(defined($opt_X)) {
  $SRC=ReadText($opt_X);
  Tokenize($SRC);
  PrintTag("$opt_X.token", $SRC);
  exit;
}

if(defined($opt_G) && defined($opt_T)) {
  ReadProduct($opt_T);
  Tokenize($SRC);
  Tokenize($TGT);
  PrintTag("$opt_G.src", $SRC);
  PrintTag("$opt_G.tgt", $TGT);
  exit;
}

### Read and Tokenize Translog log file
if (defined($opt_T)) {
  ReadTranslog($opt_T);
  ReadProduct($opt_T);
 
  Tokenize($SRC);
  Tokenize($TGT);

## check whether Keydata is complete
  CheckForward();
}

### Produce kd,fd,pu,fu files 
if (defined($opt_A)) { 
  my $fn = $opt_A;
  my $fn1 = $fn;

  if(defined($opt_O)) {$fn1 = $opt_O;}

  my($A, $B, $st) = ReadAtag($fn); 

### Check alignment of Translog log and Alignment
  if($st == 2) {CheckAln($A, $SRC);  CheckAln($B, $TGT);}
  if($st == 1) {CheckAln($B, $SRC);  CheckAln($A, $TGT);}

  ## map into $ALN  hash
  ALNatag($A, $B, $st); 

#  Produce R output tables
  SRCFixations();

## this is keyaction -> ST word mapping 
  ReverseTranslation();
  PrintFU("$fn1.fu");
  PrintPU("$fn1.pu");
  PrintFD("$fn1.fd");
  PrintKD("$fn1.kd");
  PrintST("$fn1.st");
  exit;
}

if(defined($opt_D)) {
printf STDERR "Tokenization output: $opt_D\n";

  PrintTag("$opt_D.src", $SRC);
  PrintTag("$opt_D.tgt", $TGT);
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

#sub ToUniCode {
#  my ($in) = @_;
#  
#  if($in > 127) { return sprintf('\\u%04x',ord($in)); }
#  return $in;  
#} 

  ############################################################
# Tokenize:
# insert into Text $T at $start position:       
#   token:               $T->{$start}{'tok'} = $w;
#   preceding blank:     $T->{$start}{'space'} = $blank;
#   word number:         $T->{$start}{'wnr'} = $number++;
#   end cursor position: $T->{$start}{'end'} = $cur -1;
############################################################

sub Tokenize {
  my ($T) = @_;
  my ($c);
  my $w = "";
  my $start = -1;
  my $blank = "";
  my $tok = 1;
  my $number = $TokenNumber;
  my $cur;

  foreach $cur (sort {$a <=> $b} keys %{$T}) {
    if($start == -1) {$start = $cur;}

    $c = $T->{$cur}{'c'};

    # current char is
    # tok == 0 : part of a token 
    # tok == 1 : first blank after token
    # tok ==11 : multi blank before token
    # tok == 2 : extra token
    # tok == 3 : beginning of new token

#printf STDERR "Key0: cur:$cur tok:$tok c:>$c< w:>$w< blank:>$blank< C+1:>$T->{$cur +1}{'c'}<\n";

    #############################################
    # Classify current char as
    #############################################
    # blank before token 
    if(($tok == 1 || $tok == 11) && $c =~ /[\s\n\t\r\f]/) { $tok =11;}

    # part of multi-blanks 
    elsif($c =~ /[\s\n\t\r\f]/ ) { $tok =1;}

    # X.( => X. (
    elsif($c =~ /[\.]/ 
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /[\(\)]/) { $tok = 0;}

    # abcd'[slv] => abce 'abc
    elsif(($c =~ /['`’]/ || ord($c) == 8217) 
         && $w =~ /[\p{IsAlpha}]$/
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /\p{IsAlpha}/) { 
	 $tok = 3;}

    # line breaks (y-position of char changes)
#    elsif($cur > 2 && defined($T->{$cur+1}) && 
#	  defined($T->{$cur}{'y'}) && defined($T->{$cur+1}{'y'}) && 
#	  $T->{$cur+1}{'y'} != $T->{$cur}{'y'} ) { $tok = 3;
#printf STDERR "KeyB: $c $T->{$cur+1}{'y'}, $T->{$cur}{'y'} \n";
#  } 

    # all "other" special characters are token in itself
#    elsif($c =~ /[^\p{IsAlnum}\s.\'\`\’?\,\;\:\-]/) {  printf STDERR "Hindi KeyA: $c\n"; $tok =2; }
    elsif($c =~ /[°~?!"§$%&\/()={}+*|[\]\/<>]/) { $tok =2; }
#printf STDERR "KeyC: $c\n";

    # 012'123 => 012 ' 123
    elsif($c =~ /['`’]/ 
         && $w =~ /[^\p{IsAlpha}]$/
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /[^\p{IsAlpha}]/) { $tok = 2;}

    # $'abc => $ ' abc
    elsif($c =~ /['`’]/
         && $w =~ /[^\p{IsAlnum}]/
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /\p{IsAlpha}/) { $tok = 2;}

    # abc'123 => abc ' 123
    elsif($c =~ /['`’]/
         && $w =~ /[\p{IsAlpha}]$/
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /[^\p{IsAlpha}]/) { $tok = 2;}

    # part of a number [,.:;] in numbers stay together (5,300)
    elsif($c =~ /[.,:;]/ 
         && $w =~ /\p{IsN}$/ 
         && defined($T->{$cur+1}) 
         && $T->{$cur+1}{'c'} =~ /^\p{IsN}/) { $tok = 0;}

    # one token: 32-arige  
    elsif($c =~ /-/ 
         && $w =~ /\p{IsN}$/ 
         && defined($T->{$cur+1}) 
         && $T->{$cur+1}{'c'} =~ /\p{IsAlpha}/) { $tok = 0;}

    # multi-dots stay together
    elsif($c =~ /([.,;:-])/ && $w =~ /^([$1][$1]*)$/) { $tok = 0; }

    # entity after number 1.000,12ms => 1.000,12 ms
    elsif($c =~ /[\p{IsAlpha}]/ && $w =~ /^(\p{IsN}+[:.,;]*\p{IsN}*)+$/) { $tok = 3;}

    # token after multi-dots 
    elsif($c =~ /[\p{IsAlnum}]/ && $w =~ /^[:.,;-]+$/) { $tok = 3;}

    # punctuation token
    elsif($c =~ /['`;,.:-]/) { $tok = 3;}

    # no segmentation (part of a token)
    else { $tok = 0;}

#printf STDERR "Key0a:>$w< >$blank< >$c<\t$tok\n";
    #############################################
    # Concat current char as
    #############################################
    # part of token 
    if($tok == 0) { $w .= $c; }

    # sequences of blanks
    elsif($tok == 11) { 
      $blank .= $c; 
      $start = -1;
#printf STDERR "Tok11:>$blank<\n";
    }

    # blank as tokenization border
    elsif($tok == 1) {
      $T->{$start}{'tok'} = $w;
      $T->{$start}{'end'} = $cur -1;
      $T->{$start}{'space'} = $blank;
      $T->{$start}{'wnr'} = $number++;
      if($Verbose >2 ){ printf STDERR "Tok1: $number\t>$w<\t>$blank<\t>$c<\n"; }
#d($T->{$start});
      $w = "";
      $blank = $c;
      $start = -1;
    }

    # current is an extra token
    elsif($tok == 2) {
      if($w ne "") {
        $T->{$start}{'tok'} = $w;
        $T->{$start}{'end'} = $cur -1;
        $T->{$start}{'space'} = $blank;
        $T->{$start}{'wnr'} = $number++;
      }
      if($Verbose > 2) { printf STDERR "Tok2: $number\t>$w<\t>$blank<\t>$c<\t$number\n";}
#d($T->{$start});
#d($T->{$cur});
      $T->{$cur}{'tok'} = $c;
      $T->{$cur}{'end'} = $cur;
      $T->{$cur}{'wnr'} = $number++;
      $blank=$w = "";
      $start = -1;
      $tok = 1;
    }
    # beginning of new token
    elsif($tok == 3) {
      if($w ne "") {
        $T->{$start}{'tok'} = $w;
        $T->{$start}{'end'} = $cur -1;
        $T->{$start}{'space'} = $blank;
        $T->{$start}{'wnr'} = $number++;
      }
      if($Verbose > 2) { printf STDERR "Tok3: $number\t>$w<\t>$blank<\t>$c<\n";}
#d($T->{$start});
      $w = $c;
      $blank = "";
      $start = $cur;
      $tok = 0;
    }
#printf STDERR "Key8: tok:$tok w:$w\t$blank\t$number\n";
  }

#printf STDERR "Key8: $w\t$blank\n";
  # index last token
  if($w ne "") {
      $T->{$start}{'tok'} = $w;
      $T->{$start}{'end'} = $cur;
      $T->{$start}{'space'} = $blank;
      $T->{$start}{'wnr'} = $number;
      if($Verbose >2) {printf STDERR "End$tok: $number\t>$w<\t>$blank<\t>$c<\n";}
  }

  # all chars get a word number 
  foreach $cur (sort {$a <=> $b} keys %{$T}) {
    if(defined($T->{$cur}{'wnr'})) {$number = $T->{$cur}{'wnr'};}
    else {$T->{$cur}{'wnr'} = $number;}
  }
}


############################################################
# Read src and tgt files
############################################################


sub ReadDTAG {
  my ($fn) = @_;
  my ($x, $k, $s, $D, $n); 

  if(!open(DATA, "<:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    exit ;
  }

  if($Verbose) {printf STDERR "ReadDtag Reading %s\n", $fn;g:}

  $n = 1;
  while(defined($_ = <DATA>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;
#printf STDERR "$_\n";

    if(!/<W ([^>]*)>([^<]*)/) {next;} 
    $x = $1;
    $s = $2;
    if(/id="([^"])"/ && $1 != $n) {
      printf STDERR "Read $fn: unmatching n:$n and id:$1\n";
      $n=$1;
    }

    $s =~ s/([\(\)\\\/])/\\$1/g;
    $D->{$n}{'<str>'}=$s;
#printf STDERR "\tvalue:$2\t";
    $x =~ s/\s*([^=]*)\s*=\s*"([^"]*)\s*"/AttrVal($D, $n, $1, $2)/eg;
#printf STDERR "\n";
#if(/id="14"/) {
#printf STDERR "D: $_ $s\n";
#d($D->{14});
#}
    $n++;
  }
  close (DATA);
  return $D;
}

############################################################
# Read Atag file
############################################################

sub AttrVal {
  my ($D, $n, $attr, $val) = @_;

#printf STDERR "$n:$attr:$val\t";
  $D->{$n}{$attr}=$val;
}


sub ReadAtag {
  my ($fn) = @_;
  my ($A, $B, $I, $O, $K, $fn1, $i, $io, $oo, $is, $os, $k, $D, $n); 
  my ($SrcTgt);

  if(!open(ALIGN,  "<:encoding(utf8)", "$fn.atag")) {
    printf STDERR "cannot open for reading: $fn.atag\n";
    exit 1;
  }

  printf STDERR "ReadAtag Reading: $fn.atag\n";

## read alignment file
  $n = 0;
  while(defined($_ = <ALIGN>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;

#printf STDERR "Alignment %s\n", $_;
## read aligned files
    if(/<alignFile/) {
      if(/href="([^"]*)"/) { $fn1 = $1;}

      if(!($fn1 =~ /$fn/)) {
        printf STDERR "ERROR\tHref $fn1 not same path as in $fn.atag\n";
        exit;
      }

## read reference file "a"
      if(/key="a"/) { 
        $A->{'fn'} =  $fn1;
        $A->{'D'} =  ReadDTAG( $fn1); 
        if($fn1 =~ /src$/) { $SrcTgt = 2;}
      }
## read reference file "b"
      elsif(/key="b"/) { 
        $B->{'fn'} =  $fn1;
        $B->{'D'} =  ReadDTAG( $fn1); 
        if($fn1 =~ /src$/) { $SrcTgt = 1;}
      }
      else {printf STDERR "Alignment wrong %s\n", $_;}
  
      next;
    }

    if(/<align /) {
#printf STDERR "ALN: $_\n";
      if(/in="([^"]*)"/) { $is=$1;}
      if(/out="([^"]*)"/){ $os=$1;}

      ## aligned to itself
      if($is eq $os) {next;}

      if(/in="([^"]*)"/) { 
        $K = [split(/\s+/, $1)];
        $I = {};
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { $I->{'k'} = $1; $I->{'o'}{$2} ++;}
#printf STDERR "IN:  %s\t$1\t$2\n", $K->[$i];
        }
      }
      if(/out="([^"]*)"/) { 
        $O = {};
        $K = [split(/\s+/, $1)];
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { $O->{'k'} = $1; $O->{'o'}{$2} ++;}
#printf STDERR "OUT: %s\t$1\t$2\n", $K->[$i];
        }
      }


### alignment of in checken und word nummern mappen
      if($I->{'k'} eq 'a') {
        foreach $io (keys %{$I->{'o'}}) { 
          if(defined($A->{'D'}{$io})) {
            foreach $oo (keys %{$O->{'o'}}) { $A->{'D'}{$io}{'alignment'}{$oo} ++;
#printf STDERR "IN A\t%s %s\n", $io, $oo;
             }
          }
          else {printf STDERR "$fn: Reference id 'a$io' missing in %s\n", $A->{'fn'};
#foreach my $x (sort {$a <=> $b} keys %{$A->{'D'}}) { printf STDERR "AD:  $x\n";}
	  }
      } }
      elsif($I->{'k'} eq 'b') {
        foreach $io (keys %{$I->{'o'}}) { 
          if(defined($B->{'D'}{$io})) {
            foreach $oo (keys %{$O->{'o'}}) { $B->{'D'}{$io}{'alignment'}{$oo} ++;
#printf STDERR "IN B\t%s %s\n", $io, $oo;
	    }
          }
          else {printf STDERR "$fn: Reference id 'b$io' missing in %s\n", $B->{'fn'};
#foreach my $x (sort {$a <=> $b} keys %{$B->{'D'}}) { printf STDERR "BD:  $x\n";}
	  }
        } 
      }

### aligned out="ai" im ref file checken und word nummern mappen
      if($O->{'k'} eq 'a') {
## out $io word number
        foreach $io (keys %{$O->{'o'}}) { 
          if(defined($A->{'D'}{$io})) {
            foreach $oo (keys %{$I->{'o'}}) { $A->{'D'}{$io}{'alignment'}{$oo} ++;}
          }
          else {printf STDERR "$fn: Reference id 'a%s' missing in %s\n", $io, $A->{'fn'};
	  }
      } }
      elsif($O->{'k'} eq 'b') {
        foreach $io (keys %{$O->{'o'}}) { 
          if(defined($B->{'D'}{$io})) {
            foreach $oo (keys %{$I->{'o'}}) { $B->{'D'}{$io}{'alignment'}{$oo} ++;
#printf STDERR "OUT B\t%s %s\n", $io, $oo;
	    }
          }
          else {printf STDERR "$fn: Reference id 'b%s' missing in %s\n", $io, $B->{'fn'};
foreach my $x (sort {$a <=> $b} keys %{$B->{'D'}}) { printf STDERR "BD:  $x\n";}
	  }
      } }
#printf STDERR "----- \n";

    }
  }
  close (ALIGN);
  return ($A, $B, $SrcTgt);
}

sub ALNatag {
  my ($A, $B, $SrcTgt) = @_;

  if($SrcTgt == 0) {
    printf STDERR "What is source and what target\n1:\n";
    printf STDERR "\tSource (b) %s\n",  $B->{'fn'};
    printf STDERR "\tTarget (a) %s\n",  $A->{'fn'};
    printf STDERR "or 2:\n";
    printf STDERR "\tSource (a) %s\n",  $A->{'fn'};
    printf STDERR "\tTarget (b) %s\n",  $B->{'fn'};
    $SrcTgt = <>;
  }

  # a: source b:target
  if($SrcTgt == 2) { 
    foreach my $sw (sort {$a <=> $b} keys %{$A->{'D'}}) {
      my $src =$A->{'D'}{$sw}{'cur'};
      foreach my $tw (sort {$a <=> $b} keys %{$A->{'D'}{$sw}{'alignment'}}) {
        my $tgt = $B->{'D'}{$tw}{'cur'};
#       printf STDOUT "<A src=\"%s\" tgt=\"%s\" sw=\"$sw\" tw=\"$tw\" />\n", $src, $tgt;

        if(!defined($SRC->{$src}{'wnr'})) { printf STDERR "ReadAlignment: no src cur $src\n"; d($SRC->{$src});}
        else {$ALN->{$tgt}{'src'}{$src} = $SRC->{$src}{'wnr'};}
	if($Verbose) {
         printf STDOUT "ReadAlign: sw:$sw sc:$src %s\ttw:$tw tc:$tgt %s\n", $A->{'D'}{$sw}{'str'},  $B->{'D'}{$tw}{'str'};
        }

        if(!defined($TGT->{$tgt}{'wnr'})) { printf STDERR "ReadAlignment: no tgt cur $tgt\n"; d($TGT->{$tgt});}
        else {$ALN->{$tgt}{'wnr'} = $TGT->{$tgt}{'wnr'};}
        $ALN->{$tgt}{'sw'}{$SRC->{$src}{'wnr'}}++;

      }
    }
  }

  # a:targte b:source
  elsif($SrcTgt == 1) { 
    foreach my $sw (sort {$a <=> $b} keys %{$B->{'D'}}) {
      my $src = $B->{'D'}{$sw}{'cur'};
      foreach my $tw (sort {$a <=> $b} keys %{$B->{'D'}{$sw}{'alignment'}}) {
        my $tgt = $A->{'D'}{$tw}{'cur'};
#            printf STDOUT "<A src=\"%s\" tgt=\"%s\" sw=\"$sw\" tw=\"$tw\" />\n", $src, $tgt;
        if(!defined($SRC->{$src}{'wnr'})) {  printf STDERR "ReadAlignment: no src $_";}
        else {$ALN->{$tgt}{'src'}{$src} = $SRC->{$src}{'wnr'};}
        $ALN->{$tgt}{'sw'}{$SRC->{$src}{'wnr'}}++;

        if(!defined($TGT->{$tgt}{'wnr'})) {  printf STDERR "ReadAlignment: no tgt $_";}
        else {$ALN->{$tgt}{'wnr'} = $TGT->{$tgt}{'wnr'};}
      }
    }
  }
  else {
    printf STDERR "\tSrcTgt Error: %s\n",  $A->{'fn'};
  }
}

##########################################################
# Check Alignment IDs in src,tgt and atag 
##########################################################


sub CheckATAGNumbers {
  my ($fn) = @_;
  my ($A, $B, $fn1, $i, $s); 
  my ($SrcTgt);

  if(!open(ALIGN,  "<:encoding(utf8)", $fn)) {
    printf STDERR "cannot open for reading: $fn\n";
    exit 1;
  }

  printf STDERR "CheckATAFNumbers Reading: $fn\n";
  my $is=0;
  my $os=0;
  my $ns=0;

## read alignment file
  while(defined($_ = <ALIGN>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;

    if(/<alignFile/) {
      if(/href="([^"]*)"/) { $fn1 = $1;}

#      if(!($fn1 =~ /$fn/)) {
#        printf STDERR "ERROR\tHref $fn1 not same path as in $fn.atag\n";
#        exit;
#      }

## read reference file "a"
      if(/key="a"/) { 
        $A->{'fn'} =  $fn1;
        $A->{'D'} =  ReadDTAG( $fn1); 
      }
## read reference file "b"
      elsif(/key="b"/) { 
        $B->{'fn'} =  $fn1;
        $B->{'D'} =  ReadDTAG( $fn1); 
      }
      else {printf STDERR "Alignment wrong %s\n", $_;}
  
      next;
    }

    if(/<align /) {
#printf STDERR "ALN: $_\n";
      if(/insign="([^"]*)"/) { $s=$1;}
      if(/in="([^"]*)"/) { $i =$1;}
      $is += MatchInsign($A, $B, $s, $i); 

      if(/outsign="([^"]*)"/) { $s=$1;}
      if(/out="([^"]*)"/) { $i =$1;}
      $os += MatchInsign($A, $B, $s, $i); 
      $ns ++;
    }
  }
  close(ALIGN);
  $is/=$ns;
  $os/=$ns;
  printf STDERR "Offset in:%s\tout:%s\n", $is, $os;

  if($is > 0.5 && $os > 0.5) { ReNumberATAG($fn, 1);}
}

sub  MatchInsign {
  my ($A, $B, $sign, $id) = @_;
  my ($K, $i, $n, $ab, $r);

#  $sign =~ s/[^a-zA-Z0-9]/./g;
  $K = [split(/\s+/, $id)];
  $r=0;
  for($i=0; $i <=$#{$K}; $i++) {
#    printf STDERR "MatchInSign $i in $K->[$i] \n";
    if($K->[$i] =~ /([ab])(\d+)/) { 
      $ab = $1;
      $n =$2;
      if($ab eq 'a'){
	if(!defined($A->{'D'}{$n})) {
          printf STDERR "Undefined wnr $n in $A->{'fn'} \n";
          next;
        }
        if($sign =~ /$A->{'D'}{$n}{'<str>'}/) {next;}
        elsif(defined($A->{'D'}{$n+1}) && $sign =~ /$A->{'D'}{$n+1}{'<str>'}/) {
#          printf STDERR "$A->{'fn'}:\t$id: ==> $id+1\n";
          $r=1;
	}
        elsif(defined($A->{'D'}{$n-1}) && $sign =~ /$A->{'D'}{$n-1}{'<str>'}/) {
#          printf STDERR "$A->{'fn'}:\t$id: ==> $id-1\n";
          $r=-1;
	}
#	else {$r=1;}
	if($Verbose) {
          printf STDERR "$A->{'fn'}:\t$id:$n+$r $A->{'D'}{$n+$r}{'<str>'}\tsign: $sign\n";
        }
      }
      if($ab eq 'b'){
	if(!defined($B->{'D'}{$n})) {
          printf STDERR "Undefined wnr $n in $B->{'fn'}\n";
          next;
        }
#printf STDERR "$B->{'fn'}:\t$id\n";
#d($B->{'D'}{$n+1});
        if($sign =~ /$B->{'D'}{$n}{'<str>'}/) {next;}
        elsif(defined($B->{'D'}{$n+1}) && $sign =~ /$B->{'D'}{$n+1}{'<str>'}/) {
#          printf STDERR "$B->{'fn'}:\t$id: ==> $id+1\n";
          $r=1;
	}
        elsif(defined($B->{'D'}{$n-1}) && $sign =~ /$B->{'D'}{$n-1}{'<str>'}/) {
#          printf STDERR "$B->{'fn'}:\t$id: ==> $id-1\n";
          $r=-1;
	}
#	else {$r=1;}
	if($Verbose) {
          printf STDERR "$B->{'fn'}:\t$id:$n+$r $B->{'D'}{$n+$r}{'<str>'}\tsign: $sign\n";
        }
      }
    }
  }
  return $r;
}


sub  ReNumberATAG {
  my ($fn, $n) = @_;
  my ($x);

  move($fn, "$fn.back") or die "move operation failed $!";

  printf STDERR "Moved $fn ==> $fn.back\n";
  if(!open(FILE, "<:encoding(utf8)", "$fn.back")) {
    printf STDERR "cannot open for reading: $fn.back\n";
    exit 1;
  }

  if(!open(OUT,  ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open for writing: $fn\n";
    exit 1;
  }

  while(defined($_ = <FILE>)) {
    if(/in="([^"]*)"/) {  
      $x = $1;
      $x =~ s/([ab])(\d+)/addN($n,$1,$2)/ego;
#  printf STDERR "YYY: $x\n";
      s/in="([^"]*)"/in="$x"/;  
    }
    if(/out="([^"]*)"/) {  
      $x = $1;
      $x =~ s/([ab])(\d+)/addN($n,$1,$2)/ego;
#  printf STDERR "YYY: $x\n";
      s/out="([^"]*)"/out="$x"/;  
    }
    printf OUT "$_";
  }
  close(FILE);
  close(OUT);
}

sub addN {
  my ($p, $ab, $n) = @_;

  $n+=$p;
  return "$ab$n";
}

##########################################################
# Check Alignment and tokenisation offset
##########################################################
    
sub CheckAln {
  my ($aln, $tok) = @_;
  my ($A, $cur, $alt);

  my $off = 0;
  foreach my $wnr (sort {$a <=> $b} keys %{$aln->{'D'}}) {
	#foreach my $cur (sort {$a <=> $b} keys %{$aln->{'D'}{$wnr}{'cur'}}) {
    my $cur =$aln->{'D'}{$wnr}{'cur'};
    my $alt =$aln->{'D'}{$wnr}{'<str>'};
    
	$alt =~ s/\\//g;
	
#printf STDERR "CheckAln1 $wnr:$cur off:$off\n";
#d($aln->{'D'}{$wnr});
#d($tok->{$cur});

      if(!defined($tok->{$cur+$off})) {printf STDERR "CheckAln UNDEFINED TOK AT CUR: $cur\n"; next;}

      my $f=0;
      my $ti = 1000000;
      for(my $i=0; $i<4; $i++) { 
        if(defined($tok->{$cur+$off+$i}{'tok'}) && $ti == 1000000) {$ti = $off+$i;}
        if(defined($tok->{$cur+$off-$i}{'tok'}) && $ti == 1000000) {$ti = $off-$i;}

        if(defined($tok->{$cur+$off+$i}{'tok'}) && $tok->{$cur+$off+$i}{'tok'} eq $alt) {
	      $f=1;
	      $off += $i;
	      last;
        }
        if(defined($tok->{$cur+$off-$i}{'tok'}) && $tok->{$cur+$off-$i}{'tok'} eq $alt) {
	      $f=1;
	      $off -= $i;
	      last;
	    }
      }
      if($f ==0) {
        if($ti != 1000000) {
          printf STDERR "Align token1 adjust wnr:$wnr cur:$cur --> %s\t$alt <-> %s \n", 
                         $cur+$ti, $tok->{$cur+$ti}{'tok'}; 
          $aln->{'D'}{$wnr}{'cur'} = $cur+$ti;
        }
	    else {printf STDERR "NO ALIGNMENT at wnr:$wnr '$alt'\tcur:$cur\n";}
      }
      elsif($off != 0) {
        printf STDERR "Align token2 adjust wnr:$wnr cur:$cur --> %s\t$alt <-> %s \n", 
                         $cur+$off, $tok->{$cur+$off}{'tok'}; 
        $aln->{'D'}{$wnr}{'cur'} = $cur+$off;
      }
  }
  return $A;
}

##########################################################
# Read Textfile
##########################################################

sub ReadText {
  my ($fn) = @_;
  my ($F, $T, $S);

  open(FILE,  "<:encoding(utf8)", $fn) || die ("cannot open file $fn");

  $F = '';
  while(defined($_ = <FILE>)) { $F .= $_; }
  close(FILE);
  $T = [split(//, $F)];
  for (my $i=0; $i < $#{$T}; $i++) {
    $S->{$i}{'c'} = MSunescape($T->[$i]);
  }
#  foreach my $cur (sort {$a <=> $b} keys %{$S}) {
#    printf STDERR "$cur\t$S->{$cur}{'c'}\n";
#  }
  return $S;
}


## SourceText Positions
sub ReadProduct {
  my ($fn) = @_;
  my ($type, $time, $cur, $F, $T);

#  open(FILE, $fn) || die ("cannot open file $fn");
  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  printf STDERR "ReadProduct Reading: $fn\n";

  $type = 0;
  $F = '';
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<FinalText>/) {$type =1; }
    elsif(/<SourceTextChar>/) {$type =2; }

	if($type == 1) { $F .=$_;}

	## SourceText Positions
    elsif($type == 2 && /<CharPos/) {
#print STDERR "Source: $_";
      if(/Cursor="([0-9][0-9]*)"/){$cur =$1;}
      if(/Value="([^"]*)"/)       {$SRC->{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)     {$SRC->{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)     {$SRC->{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/) {$SRC->{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/){$SRC->{$cur}{'h'} = $1;}
#printf STDERR "$SRC->{$cur}{'c'}";
    }
    if(/<\/FinalText>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
  }
  $F =~ s/^\s*<FinalText>//;
  $F =~ s/<\/FinalText>\s*$//;
  $T = [split(//, $F)];
  for (my $i=0; $i < $#{$T}; $i++) {
    $TGT->{$i}{'c'} = MSunescape($T->[$i]);
  }
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
#print STDERR "Source: $_";
      if(/Cursor="([0-9][0-9]*)"/){$cur =$1;}
      if(/Value="([^"]*)"/)       {$SRC->{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)     {$SRC->{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)     {$SRC->{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/) {$SRC->{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/){$SRC->{$cur}{'h'} = $1;}
#printf STDERR "$SRC->{$cur}{'c'}";
    }
## TranslationChar Positions
    elsif($type == 3 && /<CharPos/) {
      if(/Cursor="([0-9][0-9]*)"/) {$cur =$1;}
      if(/Value="([^"]*)"/)        {$TEXT->{$cur}{'k'} = $TRA->{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)      {$TRA->{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)      {$TRA->{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/)  {$TRA->{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/) {$TRA->{$cur}{'h'} = $1;}
      $TextLength++;
    }
## FinalText Positions
    elsif($type == 4 && /<CharPos/) {
#print STDERR "Final: $_";
      if(/Cursor="([0-9][0-9]*)"/) {$cur =$1;}
      if(/Value="([^"]*)"/)        {$TGT->{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)      {$TGT->{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)      {$TGT->{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/)  {$TGT->{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/) {$TGT->{$cur}{'h'} = $1;}
#printf STDERR "$TGT->{$cur}{'c'}";
    } 
## Mouse has no impact on insertion/deletion$SRC->{$f}{'end'}
    elsif($type == 1 && /<Mouse/) { }
    elsif($type == 1 && /<Eye/) {
      if(/Time="([0-9][0-9]*)"/)  {$time =$1;}
      if(/TT="([0-9][0-9]*)"/)    {$EYE->{$time}{'tt'} = $1;}
      if(/Win="([0-9][0-9]*)"/)   {$EYE->{$time}{'w'} = $1;}
      else{$EYE->{$time}{'w'} = 0;}
      if(/Xl="([0-9][0-9]*)"/)    {$EYE->{$time}{'xl'} = $1;}
      else{$EYE->{$time}{'xl'} = 0;}
      if(/Yl="([0-9][0-9]*)"/)    {$EYE->{$time}{'yl'} = $1;}
      else{$EYE->{$time}{'yl'} = 0;}
      if(/pl="([0-9.][0-9.]*)"/)    {$EYE->{$time}{'pl'} = $1;}
      else{$EYE->{$time}{'pl'} = 0;}
      if(/Xr="([0-9][0-9]*)"/)    {$EYE->{$time}{'xr'} = $1;}
      else{$EYE->{$time}{'xr'} = 0;}
      if(/Yr="([0-9][0-9]*)"/)    {$EYE->{$time}{'yr'} = $1;}
      else{$EYE->{$time}{'yr'} = 0;}
      if(/pr="([0-9.][0-9.]*)"/)    {$EYE->{$time}{'pr'} = $1;}
      else{$EYE->{$time}{'pr'} = 0;}
      if(/Cursor="([0-9][0-9]*)"/){$EYE->{$time}{'c'} = $1;}
      else{$EYE->{$time}{'c'} = 0;}
      if(/Xc="([0-9][0-9]*)"/)    {$EYE->{$time}{'xc'} = $1;}
      else{$EYE->{$time}{'xc'} = 0;}
      if(/Yc="([0-9][0-9]*)"/)    {$EYE->{$time}{'yc'} = $1;}
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
      if(/X="([0-9][0-9]*)"/)     {$FIX->{$time}{'x'} = $1;}
      else {$FIX->{$time}{'x'} = 0;}
      if(/Y="([0-9][0-9]*)"/)     {$FIX->{$time}{'y'} = $1;}
      else {$FIX->{$time}{'y'} = 0;}

    }
    elsif($type == 1 && /<Key/) {  $KeyLog->{$key++} = $_; }
    elsif($type == 5) {  $F .= $_; }


    if(/<\/FinalText>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
	if(/<\/Events>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/TranslationChar>/) {$type =0; }
    if(/<\/FinalTextChar>/) {$type =0; }
    if(/<\/FinalText>/) {$type =0; }
  }
  close(FILE);

#  ## Target chars from FinalText
#  $F =~ s/^\s*<FinalText>//;
#  $F =~ s/<\/FinalText>\s*$//;
#  my $T = [split(//, $F)];
#  for (my $i=0; $i < $#{$T}; $i++) {
#    $TGT->{$i}{'c'} = MSunescape($T->[$i]);
#  }

  if($Verbose >2) { 
    printf STDERR "Final TEXT:\t";
    foreach my $f (sort {$a <=> $b} keys %{$TGT}) { printf STDERR "$TGT->{$f}{'c'}"; }
    printf STDERR "\n";
  }

  # after source and target texts are read
  KeyLogAnalyse($KeyLog);
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
      else { DeleteText("");}
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
      for(my $j=0; $j < $TextLength; $j++) {  printf STDERR "%s", Rescape($TEXT->{$j}{'k'});}
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

# mouse can move cursor to different position
#  if($c != $lastCursorPos) {
#    printf STDERR "InsertText3: time:$t cur:$c lastCursorPos:$lastCursorPos\n";
#    #$c = $lastCursorPos;
#  }

#printf STDERR "InsertText2: time:$t text:$TextLength cur:$c length:$l/$#{$X}\n";

# make place for insertion in text 
  for($j=$TextLength; $j > $c; $j--) { $TEXT->{$j+$#{$X}}{'k'} = $TEXT->{$j-1}{'k'}; }
#  insert contents of $X in text 
  for($j=0; $j <= $#{$X}; $j++) { $TEXT->{$c+$j}{'k'} = $X->[$j]; }
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
    if($TEXT->{$j}{'k'} ne $X->[$i]) {
      printf STDERR "WARNING Delete missed time:$t cursor $j buff:$x\tTEXT:%s\tbuff:$i:%s\n", 
	                ord($TEXT->{$i}{'k'}), ord($X->[$i]);
      $X->[$i] = $TEXT->{$j}{'k'};
#      $TEXT->{$j}{'k'} = $X->[$i];
      last;
      for (my $k=$j-10;$k<$j+10;$k++) { 
        if($k == $j) {printf STDERR "#";} 
        if(!defined($TEXT->{$k}{'k'})) {printf STDERR "#$k";}
        else {printf STDERR "%s", $TEXT->{$k}{'k'};}
        if($k == $j) {printf STDERR "#";} 
      }
      printf STDERR "\n"; 
      for (my $k=0;$k<=$j;$k++) { printf STDERR "$k\t$TEXT->{$k}{'k'}\n"; }
      last;
    }
    elsif($Verbose > 1) { printf STDERR "WARNING Delete match  time:$t cursor:$j buff:$i:%s\n", ord($X->[$i]);}  
    $i++;
  }
  # track deletion in text 
  for($j=$c; $j<$TextLength-$l; $j++) {
    if($j+$l >= $TextLength) { last;}
#printf STDERR "DeleteText3: move %d:%s to %d:%s\n", $j+$l, $TEXT->{$j+$l}{'k'}, $j, $TEXT->{$j}{'k'};
    $TEXT->{$j}{'k'} = $TEXT->{$j+$l}{'k'};
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

  foreach my $f (sort {$a <=> $b} keys %{$TGT}) {
    if($f>=$TextLength) {last;}
    if(!defined($TEXT->{$f})) {printf STDERR "CheckForward undefined TEXT: $f\n";d($TGT->{$f});next;}
    if($TGT->{$f}{'c'} ne $TEXT->{$f}{'k'}) {
#      printf STDERR "CheckForward TGT unmatched cursor: $f >$TEXT->{$f}{'k'}<\t>$TGT->{$f}{'c'}<\n"; 
      printf STDERR "CheckForward TGT unmatched cursor: $f >%s<\t>%s<\n", ord($TEXT->{$f}{'k'}), ord($TGT->{$f}{'c'}); 
	  next;
      printf STDERR "Prod. TEXT:\t"; 
      foreach my $m (sort {$a <=> $b} keys %{$TEXT}) { 
        if($m <= $f-20) {next;} 
        if($m >= $f+20) {last;} 
        if($m >= $TextLength) {last;} 
        if($m == $f) {printf STDERR "#";} 
        printf STDERR "$TEXT->{$m}{'k'}"; 
        if($m == $f) {printf STDERR "#";} 
      }
      printf STDERR "\n"; 
      printf STDERR "Final TEXT:\t"; 
      foreach my $m (sort {$a <=> $b} keys %{$TGT}) { 
        if($m <= $f-20) {next;} 
        if($m >= $f+20) {last;} 
        if($m >= $TextLength) {last;} 
        if($m == $f) {printf STDERR "#";} 
        printf STDERR "$TGT->{$m}{'c'}"; 
        if($m == $f) {printf STDERR "#";} 
      }
      printf STDERR "\n"; 
#      d($TEXT->{$f});
      next;
    }
  }
}

##########################################################
# Map SRC gaze and fixations on ST
##########################################################

my $NotAligned;

sub SRCFixations {
  my ($k);

#  d($TGT);
#  foreach $k (sort {$a <=> $b} keys %{$TGT}) {  printf STDERR "$k:$TGT->{$k}{'c'}";}
#  printf STDERR "\n";

  ## initialise wnr in TEXT and TGT
  my $n = 0;
  my $c = 0;
  foreach $k (sort {$a <=> $b} keys %{$TGT}) { 
    if(!defined($TEXT->{$k})) {printf STDERR "SRCFixations undefined TEXT cur: $k\n";next;}
    if(!defined($TEXT->{$k}{'k'})) {printf STDERR "SRCFixations undefined TEXT char at cur: $k\n";d($TEXT->{$k});next;}
    if(!defined($TGT->{$k}{'c'})) {printf STDERR "SRCFixations undefined TGT char at cur: $k\n";d($TGT->{$k});next;}

    if($TGT->{$k}{'c'} ne $TEXT->{$k}{'k'}) {
      printf STDERR "SRCFix unmatched TGT cursor: $k: TEXT:>%s<\tTGT:>%s<\n", ord($TEXT->{$k}{'k'}), ord($TGT->{$k}{'c'}); 
      next;
    }
    if($TGT->{$k}{'wnr'} != $n) { $c=$k; $n=$TGT->{$k}{'wnr'};}
    $TEXT->{$k}{'wnr'} = $TGT->{$k}{'wnr'};
    $TEXT->{$k}{'wcur'} = $c;
#printf STDERR "SRCFixations $k %s %s\n", $TEXT->{$k}{'wcur'}, $TEXT->{$k}{'wnr'}; 
  }

  $n=0;
  foreach $k (sort {$a <=> $b} keys %{$TEXT}) { 
    if($k>=$TextLength) {last;}
    
    if(!defined($TEXT->{$k}{'wnr'})) {
      printf STDERR "SRCFix undefined TEXT cursor $k\t$TEXT->{$k}{'k'} setting to cur:$n wcur:$c\n";
      $TEXT->{$k}{'wnr'} = $n;
      $TEXT->{$k}{'wcur'} = $c;
    } 
    else {
      $n = $TEXT->{$k}{'wnr'};
      $c = $TEXT->{$k}{'wcur'};
    }
  }

  ## initialise TEXT words in KEY
  foreach $k (sort {$a <=> $b} keys %{$EYE}) { 
    if($EYE->{$k}{'w'} != 1) {next;}
    $c = $EYE->{$k}{'c'};
    if(defined($SRC->{$c})) { $EYE->{$k}{'wnr'}{$SRC->{$c}{'wnr'}} ++; }
    elsif(!defined($NotAligned->{'src'}{$c}))  { 
      printf STDERR "SRCFix Undefined SRC word: time:$k cursor:$c\n"; 
      $NotAligned->{'src'}{$c} ++;
    }
  }

  ## initialise TEXT words in KEY
  foreach $k (sort {$a <=> $b} keys %{$FIX}) { 
    if($FIX->{$k}{'w'} != 1) {next;}
    $c = $FIX->{$k}{'c'};
    if(defined($SRC->{$c})) { $FIX->{$k}{'wnr'}{$SRC->{$c}{'wnr'}} ++; }
    elsif(!defined($NotAligned->{'src'}{$c}))  { 
      printf STDERR "SRCFix Undefined SRC word: cursor:$c\n"; 
      $NotAligned->{'src'}{$c} ++;
    }
  }
}


############################################################
# Key-to-ST mapping
############################################################

sub ReverseTranslation {
  my ($k, $j, $c);
  my ($F, $E);

  if(defined($FIX)) { $F = [sort {$b <=> $a} keys %{$FIX}];}
  if(defined($EYE)) { $E = [sort {$b <=> $a} keys %{$EYE}];}
  my $e=0;
  my $f=0;

  my $wnr=-1; my $wcur=-1;
  foreach $k (sort {$b <=> $a} keys %{$KEY}) {
    $c = $KEY->{$k}{'c'};

#printf STDERR "ReverseTranslation E:$#{$E}  F:$#{$F} k:%sk c:%s\n";
#d($FIX);
#d($EYE);
#printf STDERR "ReverseTranslation f:$f k:$k c:$c\n";
#d($ALN);

    ## Assign WNR to FIX samples in trarget window
    while($f <= $#{$F} && $F->[$f] > $k) {
      if($FIX->{$F->[$f]}{'w'} == 2) {
        my $e2 = $FIX->{$F->[$f]}{'c'};
        if(!defined($TEXT->{$e2}{'wnr'})) {
          printf STDERR "Undef wnr in TEXT cur:$e2 $TextLength\n"; 
	  d($FIX->{$F->[$f]});
        }
        elsif($FIX->{$F->[$f]}{'c'} >= $TextLength) {
          printf STDERR "Target FIX at time:$F->[$f] cur:$FIX->{$F->[$f]}{'c'} >= TEXT:$TextLength\n"; 
	  $e2 = $TextLength-1;
        }

        if(defined($ALN->{$TEXT->{$e2}{'wcur'}})) {
	  $FIX->{$F->[$f]}{'wnr'} = $ALN->{$TEXT->{$e2}{'wcur'}}{'sw'}; 
        }
#	elsif (!defined($NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}})) { 
#	  printf STDERR "Unaligned TGT: cur:$e2 word:$TEXT->{$e2}{'wnr'}\n"; $NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}}++;
#        }
      }
      $f++; 
    }

    ## Assign WNR to EYE samples in trarget window
    while($e <= $#{$E} && $E->[$e] > $k) {
      my $e1 = $E->[$e];
      if($EYE->{$E->[$e]}{'w'} == 2) {
        my $e2 = $EYE->{$E->[$e]}{'c'};
#        printf STDERR "ReverseTranslation EYE:$e $e1 $e2\n"; 
#	d($TEXT->{$e2});

        if(!defined($TEXT->{$e2}{'wcur'})) {
          printf STDERR "Undef wnr in TEXT cur:$e2 $TextLength\n"; 
        }
        if($EYE->{$e1}{'c'} >= $TextLength) {
          printf STDERR "Target EYE at time:$e1 cur:$EYE->{$e1}{'c'} >= TEXT:$TextLength\n"; 
 	  $e1 = $TextLength-1;
        }

        if(defined($ALN->{$TEXT->{$e2}{'wcur'}})) {
          $EYE->{$e1}{'wnr'} = $ALN->{$TEXT->{$e2}{'wcur'}}{'sw'}; 
#	printf STDERR "ReverseTranslation OK EYE cur:$e2 word:$TEXT->{$e2}{'wcur'}\n"; 
	}
#	elsif (!defined($NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}})) { 
#	  printf STDERR "Unaligned TGT: cur:$e2 word:$TEXT->{$e2}{'wnr'}\n"; $NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}}++;
#        }
      }
      $e++; 
    }

###########################################
# Key -> word mapping
#

    if($KEY->{$k}{'t'} eq "ins") {
# Check Consistency of Keys and TEXT
      if(!defined($TEXT->{$c}{'k'})) {printf STDERR "ReverseTranslation undefined: $c $KEY->{$k}{'k'}\n"; next;}
      if(!defined($TEXT->{$c}{'wnr'})) {printf STDERR "ReverseTranslation WNR: $c $KEY->{$k}{'k'}\n"; next;}
      if($KEY->{$k}{'k'} ne $TEXT->{$c}{'k'}) {
        printf STDERR "ReverseTranslation no match: $c $KEY->{$k}{'k'} $TEXT->{$c}{'k'}\n"; 
        foreach my $m (sort {$a <=> $b} keys %{$TEXT}) { 
          if($m >= $TextLength) {last;} 
	  if($m == $c) {printf STDERR "#";} 
	  printf STDERR "$TEXT->{$m}{'k'}"; 
        }
        printf STDERR "\n"; 
        next;
      }
# remember last wnr
      $wnr = $KEY->{$k}{'wnr'} = $TEXT->{$c}{'wnr'};
      $wcur = $KEY->{$k}{'wcur'} = $TEXT->{$c}{'wcur'};
      for($j=$c; $j<$TextLength-1; $j++) { 
        $TEXT->{$j}{'k'} = $TEXT->{$j+1}{'k'}; 
        $TEXT->{$j}{'wnr'} = $TEXT->{$j+1}{'wnr'}; 
        $TEXT->{$j}{'wcur'} = $TEXT->{$j+1}{'wcur'}; 
      }
#printf STDERR "INSERT cur: $c $KEY->{$k}{'k'} wnr:$KEY->{$k}{'wnr'}\t"; 
#for(my $i=0; $i<$TextLength-1; $i++) { printf STDERR "$TEXT->{$i}{'k'}"; }
#printf STDERR "\n";

      $TextLength--;
    }

    elsif($KEY->{$k}{'t'} eq "del") {

# if left and right are same wnr: 
#printf STDERR "D wnr:$wnr c:$c k:$k\n";
#d($TEXT->{$c});
#d($KEY->{$k});

      if(!defined($TEXT->{$c}) || !defined($TEXT->{$c}{'wnr'})) {
        printf STDERR "ReverseTranslation WNR: $c $KEY->{$k}{'k'}\n"; 
        my $c1 =$c;
        while(!defined($TEXT->{$c1}) || !defined($TEXT->{$c1}{'wnr'})) {$c1 --;}
        $TEXT->{$c}{'wcur'} = $TEXT->{$c1}{'wcur'};
        $TEXT->{$c}{'wnr'} = $TEXT->{$c1}{'wnr'};
        $TEXT->{$c}{'k'} = $KEY->{$k}{'k'};
        $TextLength++;
        next;
      }
      elsif(defined($TEXT->{$c-1}) && $TEXT->{$c-1}{'wnr'} == $TEXT->{$c}{'wnr'}) { $wnr = $TEXT->{$c}{'wnr'}; $wcur = $TEXT->{$c}{'wcur'};}
      elsif(defined($TEXT->{$c-1}) && $TEXT->{$c-1}{'wnr'} > $wnr || $TEXT->{$c}{'wnr'} < $wnr) {
        if($TEXT->{$c}{'k'} =~ /\s/)      { $wnr = $TEXT->{$c-1}{'wnr'}; $wcur = $TEXT->{$c-1}{'wcur'};}
	elsif($TEXT->{$c-1}{'k'} =~ /\s/) { $wnr = $TEXT->{$c}{'wnr'}; $wcur = $TEXT->{$c}{'wcur'};}
	else { $wnr = $TEXT->{$c}{'wnr'}; $wcur = $TEXT->{$c}{'wcur'};}
      }
      elsif($wnr == -1) { $wnr = $TEXT->{$c}{'wnr'}; $wcur = $TEXT->{$c}{'wcur'};}

#printf STDERR "DELETED: cur:$c wnr:$wnr  $TEXT->{$c-1}{'wnr'}:$TEXT->{$c-1}{'k'}  $TEXT->{$c}{'wnr'}:$TEXT->{$c}{'k'}  ins:$KEY->{$k}{'k'} \n"; 
#for (my $i=$c-3; $i<$c+3; $i++) { printf STDERR "$TEXT->{$i}{'k'}";}
#printf STDERR "\n";


      for($j=$TextLength; $j>$c; $j--) { 
        $TEXT->{$j}{'wnr'} = $TEXT->{$j-1}{'wnr'}; 
        $TEXT->{$j}{'wcur'} = $TEXT->{$j-1}{'wcur'}; 
        $TEXT->{$j}{'k'} = $TEXT->{$j-1}{'k'}; 
      }
      $KEY->{$k}{'wnr'}=$TEXT->{$c}{'wnr'} = $wnr;
      $KEY->{$k}{'wcur'}=$TEXT->{$c}{'wcur'} = $wcur;
      $TEXT->{$c}{'k'} = $KEY->{$k}{'k'};

#for (my $i=$c-3; $i<$c+3; $i++) { printf STDERR "$TEXT->{$i}{'k'}";}
#printf STDERR "\n";

      $TextLength++;
    }
    else { printf STDERR "ERROR undefined KEYSTROKE:\n"; d($KEY->{$k}); }
  }

  while($f <= $#{$F}) {
    if($FIX->{$F->[$f]}{'w'} == 2) {
      my $e2 = $FIX->{$F->[$f]}{'c'}; 
      if(defined($ALN->{$TEXT->{$e2}{'wcur'}})) {
        $FIX->{$F->[$f]}{'wnr'} = $ALN->{$TEXT->{$e2}{'wcur'}}{'src'}; 
      }
#      elsif (!defined($NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}})) { 
#        printf STDERR "Unaligned TGT: cur:$e2 word:$TEXT->{$e2}{'wnr'}\n"; $NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}}++;
#      }
    }
    $f++;
  }
  while($e <= $#{$E}) {
    if($EYE->{$E->[$e]}{'w'} == 2) {
      my $e2 = $EYE->{$E->[$e]}{'c'};
      if(defined($ALN->{$TEXT->{$e2}{'wcur'}})) {
        $EYE->{$E->[$e]}{'wnr'} = $ALN->{$TEXT->{$e2}{'wcur'}}{'src'}; 
#	printf STDERR "ReverseTranslation OK EYE cur:$e2 word:$TEXT->{$e2}{'wcur'}\n"; 
      }
#      elsif (!defined($NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}})) { 
#        printf STDERR "Unaligned TGT: cur:$e2 word:$TEXT->{$e2}{'wnr'}\n"; $NotAligned->{'tgt'}{$TEXT->{$e2}{'wcur'}}++;
#      }
    }
    $e++; 
  }

#  foreach $k (sort {$a <=> $b} keys %{$KEY}) {
#    printf STDERR "$k\t$KEY->{$k}{'c'}\t$KEY->{$k}{'k'}\t$KEY->{$k}{'wnr'}\t$KEY->{$k}{'t'}\n";
#  }


## CHECK BACKWARD
  foreach $k (sort {$a <=> $b} keys %{$TRA}) {
    if(!defined($TRA->{$k}))     {printf STDERR "CheckBackward TRA: $k $TRA->{$k}\n"; next;}
    if($TRA->{$k}{'c'} ne $TEXT->{$k}{'k'}) {printf STDERR "CheckBackward TRA: $k %s\t%s\n", ord($TEXT->{$k}{'k'}), ord($TRA->{$k}{'c'}); next;};
  }
}


################################################
#  PRINTING
################################################

## Print table with (wnr, token) 
sub PrintST {
  my ($fn) = @_; 
  my ($f, $s); 

#source file (.src)
  if(!defined( $SRC )) { 
    printf STDERR "PrintST: undefined SOURCE\n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }
  if($Verbose){ printf STDERR "Writing: $fn\n";}
  printf FILE "wnr\ttoken\n";
  foreach $f (sort {$a <=> $b} keys %{$SRC}) {
#printf STDERR "SRC:\n";
#d($SRC->{$f});
    if(!defined($SRC->{$f}{'tok'})) { next;}

    printf FILE "%d\t%s\n", $SRC->{$f}{'wnr'}, Rescape($SRC->{$f}{'tok'});
  }
  close (FILE);
}

## Print DTAG tag format
sub PrintTag {
  my ($fn, $Tag) = @_; 
  my ($f, $s); 

#source file (.src)
  if(!defined( $Tag )) { 
    printf STDERR "PrintTag: undefined tag $fn\n";
    return ;
  }
  if(!open(FILE,  ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }
  if($Verbose){ printf STDERR "Writing: $fn\n";}
#  d($Tag);
  my $w = 0;

  printf FILE "<Text>\n";
  foreach $f (sort {$a <=> $b} keys %{$Tag}) {
#printf STDERR "Tag: $_";
    if(!defined($Tag->{$f}{'tok'})) { next;}
    $s = '';
    if(defined($Tag->{$f}{'end'}) && defined($Tag->{$f}{'x'})) {
#printf STDERR "Tag: $f  $Tag->{$f}{'end'}\t$Tag->{$f}{'tok'}\n";
      $w = $Tag->{$Tag->{$f}{'end'}}{'x'} + $Tag->{$Tag->{$f}{'end'}}{'w'} - $Tag->{$f}{'x'};
    }

    $s .= "cur=\"$f\"";
    if(defined($Tag->{$f}{'wnr'})) { $s .= " id=\"$Tag->{$f}{'wnr'}\""; }

      #if(defined($Tag->{$f}{'space'}) && $Tag->{$f}{'space'} ne "") {$s .= " space=\"$Tag->{$f}{'space'}\"";}
    if(defined($Tag->{$f}{'space'}) && $Tag->{$f}{'space'} ne "") {
       my $e = escape($Tag->{$f}{'space'});
       $s .= " space=\"$e\"";
    }
#    if(defined($Tag->{$f}{'x'}))   {$s .= " x=\"$Tag->{$f}{'x'}\"";}
#    if(defined($Tag->{$f}{'y'}))   {$s .= " y=\"$Tag->{$f}{'y'}\"";}
#    if(defined($Tag->{$f}{'w'}))   {$s .= " w=\"$w\"";}
#    if(defined($Tag->{$f}{'h'}))   {$s .= " h=\"$Tag->{$f}{'h'}\"";}

    printf FILE "<W %s>%s</W>\n", $s, escape($Tag->{$f}{'tok'});
#      printf STDERR "<W %s>%s</W>\n", $s, $Tag->{$f}{'tok'};
  }
  printf FILE "</Text>\n";
  close (FILE);
}


sub PrintTra {
  my ($fn) = @_; 
  my ($f, $s); 

#Translation (.tra)
  if(!defined( $TRA )) {
    printf STDERR "PrintTra: undefined Translation\n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }
  if($Verbose){ printf STDERR "Writing: $fn\n";}
  foreach $f (sort {$a <=> $b} keys %{$TRA}) {
#printf STDERR "TRA:";
#d($TRA->{$f});
    $s = "cur=\"$f\"";
    if(defined($TRA->{$f}{'c'}))   {$s .= " str=\"" . escape($TRA->{$f}{'c'}) . "\"";}
#      if(defined($TRA->{$f}{'x'}))   {$s .= " x=\"$TRA->{$f}{'x'}\"";}
#      if(defined($TRA->{$f}{'y'}))   {$s .= " y=\"$TRA->{$f}{'y'}\"";}
#      if(defined($TRA->{$f}{'w'}))   {$s .= " w=\"$TRA->{$f}{'w'}\"";}
#      if(defined($TRA->{$f}{'h'}))   {$s .= " h=\"$TRA->{$f}{'h'}\"";}

#      printf STDERR "<W %s>%s</W>\n", $s, escape($TRA->{$f}{'tok'});
    printf FILE "<W $s />\n";
  }
  close (FILE);
}

sub PrintEye {
  my ($fn) = @_; 
  my ($f, $s); 

#sample file
  if(!defined( $EYE )) { 
    printf STDERR "PrintEye: Undefined GAZE DATA\n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }
  if($Verbose){ printf STDERR "Writing: $fn\n";}
  #d($EYE);
  foreach $f (sort {$a <=> $b} keys %{$EYE}) {
    if(!defined($EYE->{$f}{'w'}) || $EYE->{$f}{'w'} == 0 ) { next;}
    my $s = '';
#d( $EYE->{$f});
    $s .= "Time=\"$f\""; 
    if(defined($EYE->{$f}{'tt'})){$s .= " tt=\"$EYE->{$f}{'tt'}\"";}
    if(defined($EYE->{$f}{'w'})) {$s .= " win=\"$EYE->{$f}{'w'}\"";}
    if(defined($EYE->{$f}{'c'})) {$s .= " cur=\"$EYE->{$f}{'c'}\"";}
    if(defined($EYE->{$f}{'wnr'})) {$s .= " wnr=\"$EYE->{$f}{'wnr'}\"";}
    if(defined($EYE->{$f}{'xc'})){$s .= " xc=\"$EYE->{$f}{'xc'}\"";}
    if(defined($EYE->{$f}{'yc'})){$s .= " yc=\"$EYE->{$f}{'yc'}\"";}
    if(defined($EYE->{$f}{'xl'})){$s .= " xl=\"$EYE->{$f}{'xl'}\"";}
    if(defined($EYE->{$f}{'yl'})){$s .= " yl=\"$EYE->{$f}{'yl'}\"";}
    if(defined($EYE->{$f}{'pl'})){$s .= " pl=\"$EYE->{$f}{'pl'}\"";}
    if(defined($EYE->{$f}{'xr'})){$s .= " xr=\"$EYE->{$f}{'xr'}\"";}
    if(defined($EYE->{$f}{'yr'})){$s .= " yr=\"$EYE->{$f}{'yr'}\"";}
    if(defined($EYE->{$f}{'pr'})){$s .= " pr=\"$EYE->{$f}{'pr'}\"";}
    printf FILE "<E $s \>\n";
  }
  close (FILE);
}

sub PrintFix {
  my ($fn) = @_; 
  my ($f, $s); 

#sample fixations
  if(!defined( $FIX )) { 
    printf STDERR "PrintFix: undefined Fixation Datan\n";
    return ;
  }
  if(!open(FILE,  ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }
  if($Verbose){ printf STDERR "Writing: $fn\n";}
  foreach $f (sort {$a <=> $b} keys %{$FIX}) {
#  d($FIX->{$f});
    my $s = "time=\"$f\"";
    if(defined($FIX->{$f}{'tt'})){ $s .= " tt=\"$FIX->{$f}{'tt'}\"";}
    if(defined($FIX->{$f}{'w'})) { $s .= " win=\"$FIX->{$f}{'w'}\"";}
    if(defined($FIX->{$f}{'c'})) { $s .= " cur=\"$FIX->{$f}{'c'}\"";}
    if(defined($FIX->{$f}{'wnr'})) {$s .= " wnr=\"$FIX->{$f}{'wnr'}\"";}
    if(defined($FIX->{$f}{'d'})) { $s .= " dur=\"$FIX->{$f}{'d'}\"";}
    if(defined($FIX->{$f}{'x'})) { $s .= " x=\"$FIX->{$f}{'x'}\"";}
    if(defined($FIX->{$f}{'y'})) { $s .= " y=\"$FIX->{$f}{'y'}\"";}
    printf FILE "<F $s />\n";
  }
  close (FILE);
}

sub PrintKey {
  my ($fn) = @_;
  my ($f, $s);

#sample keyboard actions
  if(!defined( $KEY )) { 
    printf STDERR "PrintKey: undefined KEY data \n";
    return ;
  }
  if(!open(FILE, ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }
  if($Verbose){ printf STDERR "Writing: $fn\n";}
  foreach $f (sort {$a <=> $b} keys %{$KEY}) {
#    d($KEY->{$f});

    my $s = "time=\"$f\"";
    if(defined($KEY->{$f}{'x'})) { $s .= " x=\"$KEY->{$f}{'x'}\"";}
    if(defined($KEY->{$f}{'y'})) { $s .= " y=\"$KEY->{$f}{'y'}\"";}
    if(defined($KEY->{$f}{'w'})) { $s .= " w=\"$KEY->{$f}{'w'}\"";}
    if(defined($KEY->{$f}{'h'})) { $s .= " h=\"$KEY->{$f}{'h'}\"";}
    if(defined($KEY->{$f}{'t'})) { $s .= " type=\"$KEY->{$f}{'t'}\"";}
    if(defined($KEY->{$f}{'c'})) { $s .= " cur=\"$KEY->{$f}{'c'}\"";}
    if(defined($KEY->{$f}{'k'})) { $s .= " str=\"" . escape($KEY->{$f}{'k'}) . "\"";}
    printf FILE "<K $s />\n";
#    printf STDERR "<K $s />\n";
  }
  close (FILE);
}

sub PrintKD {
  my ($fn) = @_;
  my ($n, $t, $s, $src, $R);

  if(!defined( $ALN )) { 
    printf STDERR "PrintKD: undefined Alignment data \n";
    return ;
  }
  if(!defined( $KEY )) { 
    printf STDERR "PrintKD: undefined Keyboard data \n";
    return ;
  }
  if($fn ne "") {
    open(STDOUT, '>:encoding(utf8)', $fn) || die "Can't redirect stdout to $fn";
  }

  $n = 0;
#printf STDERR "n\ttime\ttype\tcur\tchr\tsrc\ttgt\n";
  printf STDOUT "n\ttime\ttype\tcur\tchr\tsrc\ttgt\n";
  foreach $t (sort  {$a <=> $b} keys %{$KEY}) {
## unit number

    $s = sprintf("%s\t%s\t%s\t%s\t%s\t", 
         $n++, $t, $KEY->{$t}{'t'}, $KEY->{$t}{'c'}, Rescape($KEY->{$t}{'k'}));

    # source word
#    if(!defined($ALN->{$KEY->{$t}{'wcur'}})) {printf STDERR "PrintKD: unmatched word \n"; d($KEY->{$t});}
    if(!defined($ALN->{$KEY->{$t}{'wcur'}}) ||
        defined($ALN->{$KEY->{$t}{'wcur'}}{'NOK'})) { $s .= "-1";}
    else {
      my $k = 0;
      foreach $src (sort  {$a <=> $b} keys %{$ALN->{$KEY->{$t}{'wcur'}}{'src'}}) {
        if($k >0) {$s .= "+";}
        $s .= $ALN->{$KEY->{$t}{'wcur'}}{'src'}{$src};
	$k++;
      } 
      if($k == 0) { $s .= "-1";}
    }
    printf STDOUT "%s\t%s\n", $s, $KEY->{$t}{'wnr'};	# target word
#printf STDERR "%s\t%s\n", $s, $KEY->{$t}{'wnr'};	# target word

  }
  close
}

##### Fixation data

sub PrintFD {
  my ($fn) = @_;
  my ($n, $t, $src, $R);

  if(!defined( $FIX )) { 
    printf STDERR "PrintFD: undefined Fixation data \n";
    return ;
  }
  if($fn ne "") {
    open(STDOUT, '>:encoding(utf8)', $fn) || die "Can't redirect stdout to $fn";
  }

  $n = 0;
  printf STDOUT "n\ttime\twin\tdur\tfu\tchr\twnr\n";
  foreach $t (sort  {$a <=> $b} keys %{$FIX}) {
#    printf STDERR "PrintFD:\n";
#    d($FIX->{$t});

    printf STDOUT "%s\t", $n++;                 # number
    printf STDOUT "%s\t", $t;                   # time
    printf STDOUT "%s\t", $FIX->{$t}{'w'};      # window
    printf STDOUT "%s\t", $FIX->{$t}{'d'};      # fixation duration
    printf STDOUT "%s\t", $FIX->{$t}{'fu'};     # fixation Unit
    printf STDOUT "%s\t", $FIX->{$t}{'c'};      # cursor
    if(defined($FIX->{$t}{'wnr'})) {
      foreach my $s (sort  {$a <=> $b} keys %{$FIX->{$t}{'wnr'}}) {printf STDOUT "$s"; last;}   # wnr
    }
    else {printf STDOUT "-1\t"; }   # wnr
    printf STDOUT "\n";

  }
  close
}


##### FIXATION UNITS 

sub PrintFU {
  my ($fn) = @_;
  my ($t, $dur, $T, $pause);

  if(!defined( $FIX )) { 
    printf STDERR "PrintFU: undefined Fixation data \n";
    return ;
  }
  if($fn ne "") {
    open(STDOUT, '>:encoding(utf8)', $fn) || die "Can't redirect stdout to $fn";
  }

  my $start = 0;
  my $win = 0;
  my $end = 0;
  my $fix = "";
  my $n = 0;
  my $m = 0;
#printf STDERR "n\tstart\tdur\twin\tpause\tparal\tfixes\n";
  printf STDOUT "n\tstart\tdur\twin\tpause\tparal\tfixes\n";
  foreach $t (sort  {$a <=> $b} keys %{$FIX}) {
#printf STDERR "YYYY\n";
#d($FIX->{$t});
#printf STDERR "XXXX $t $n $end $start $win\n";
#printf STDERR "XXX1 $t $start $end $n $FIX->{$t}{'w'}  $FIX->{$t}{'d'}\t$win\n";
    if($start != 0 && $m >2 && ((($t - $end) > $MaxFixGap) || $FIX->{$t}{'w'} != $win)) {
      if($m > 2 ) { 
        $n++;
        $dur = $end - $start;
        $pause = $t - $end;
#printf STDERR "$n\t$start\t$dur\t$win\t$pause\t---\t$fix\n";
        printf STDOUT "$n\t$start\t$dur\t$win\t$pause\t---\t$fix\n";
        $FIX->{$start}{'fu'} = $n;
        $FIX->{$T}{'fu'} = $n;
        $FIX->{$T}{'end'} = $n;
      }
      $start = 0;
    }
    if($start == 0) {$start = $t;  $m=0; $fix = "";}
    if($FIX->{$t}{'w'} <= 0 ) { $start=0; next;}
    if(defined($FIX->{$t}{'wnr'})) {
      foreach my $s (sort  {$a <=> $b} keys %{$FIX->{$t}{'wnr'}}) { $fix .= "$s+"; }   # wnr
#      $fix .= $FIX->{$t}{'wnr'}."+";
      $m ++;
      $end = $t + $FIX->{$t}{'d'};
    }
    $T = $t;
    $win = $FIX->{$t}{'w'};
  }
  $n=0;
  foreach $t (sort  {$a <=> $b} keys %{$FIX}) {
    if(defined($FIX->{$t}{'fu'})) { $n = $FIX->{$t}{'fu'};}
    elsif(defined($FIX->{$t}{'end'})) { $n = 0;}
    else {$FIX->{$t}{'fu'} = $n;}
  }
}

##### Production UNITS 

my $PuHash = {};

sub PrintPU {
  my ($fn) = @_;
  my ($t, $dur, $pause);

  if(!defined( $FIX )) { 
    printf STDERR "PrintPU: undefined Keyboard data \n";
    return ;
  }
  if($fn ne "") {
    open(STDOUT, '>:encoding(utf8)', $fn) || die "Can't redirect stdout to $fn";
  }

  my $start = 0;
  my $end = 0;
  my $src = "";
  my $tgt = "";
  my $str = "";
  my $ins = 0;
  my $del = 0;
  my $Del = 0;
  my $n = 0;
  printf STDOUT "n\tstart\tdur\tpause\tparal\tins\tdel\tsrc\ttgt\tstr\n";
  foreach $t (sort  {$a <=> $b} keys %{$KEY}) {
#d($KEY->{$t});
    if($start == 0) {$start = $t;}
#printf STDERR "XXXX $n $end $t $MaxKeyGap\n";
    if($end > 0 && (($t - $end) > $MaxKeyGap)) {
      $dur = $end - $start;
      $pause = $t - $end;
      if($Del == 1) {$Del = 0; $str .= "]";}
      foreach my $h (sort  {$a <=> $b} keys %{$PuHash->{'src'}}) { $src .= $h . "+"; }
      foreach my $h (sort  {$a <=> $b} keys %{$PuHash->{'tgt'}}) { $tgt .= $h . "+"; }
      if($src eq '') {$src=-1;}
      if($tgt eq '') {$tgt=-1;}
      $str = Rescape($str);
      printf STDOUT "$n\t$start\t$dur\t$pause\t---\t$ins\t$del\t$src\t$tgt\t$str\n";
      $n++;
      $ins = 0;
      $del = 0;
      $src = "";
      $tgt = "";
      $str = "";
      $PuHash = {};
      $start = $t;
    }
    $KEY->{$t}{'pu'} = $n;
    $PuHash->{'tgt'}{$KEY->{$t}{'wnr'}} ++;
    Tcur2Swnr($KEY->{$t}{'wcur'});
    if($KEY->{$t}{'t'} eq 'del' && $Del == 0) {$Del = 1; $str .= "[";}
    if($KEY->{$t}{'t'} eq 'ins' && $Del == 1) {$Del = 0; $str .= "]";}
    $str .= $KEY->{$t}{'k'};

    if($KEY->{$t}{'t'} eq 'del') {$del ++;}
    else {$ins ++;}
    $end = $t;
  }

  # last PU
  if($str ne "") {
    if($Del == 1) { $str .= "]";}
    $dur = $end - $start;
    $pause = 0; # 
    foreach my $h (sort  {$a <=> $b} keys %{$PuHash->{'src'}}) { $src .= $h . "+"; }
    foreach my $h (sort  {$a <=> $b} keys %{$PuHash->{'tgt'}}) { $tgt .= $h . "+"; }
    if($src eq '') {$src=-1;}
    if($tgt eq '') {$tgt=-1;}
    $str = Rescape($str);
    printf STDOUT "$n\t$start\t$dur\t$pause\t---\t$ins\t$del\t$src\t$tgt\t$str\n";
  }
}

sub  Tcur2Swnr{
  my ($cur) = @_;

  my $s = "";

  ## map cursor position on wnr
  if(!defined($ALN->{$cur})) { 
    if(defined($TGT->{$cur}{'NOK'})) {return;}
    if(defined($TGT->{$cur}{'tok'})) { 
      printf STDERR "Tcur2Swnr unaligned tgt $cur\t$TGT->{$cur}{'tok'}\n"; 
    } 
    else {printf STDERR "Tcur2Swnr unmatched tgt $cur\n";} 
    $TGT->{$cur}{'NOK'} = 1;
#    $PuHash->{'src'}{-1}++;
    return "0";
  }
  foreach my $src (sort  {$a <=> $b} keys %{$ALN->{$cur}{'src'}}) {
    $PuHash->{'src'}{$ALN->{$cur}{'src'}{$src}}++;
  }
  return $s;
}
