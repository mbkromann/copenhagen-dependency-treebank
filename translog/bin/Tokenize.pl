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
  "Tokenisation of Translog file: \n".
  "  -T in:  Translog XML <filename>\n".
  "  out: Write Translog file with Tokens to STDOUT\n".
  "Options:\n".
  "  -D out: Write in {.src,.tgt} file\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_D $opt_T $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:D:v:h');

die $usage if defined($opt_h);

my $SRC = undef;
my $TGT = undef;
my $Verbose = 0;
my $SourceLanguage = '';
my $TargetLanguage = '';

if (defined($opt_v)) {$Verbose = $opt_v;}
if (!defined($opt_T)) {die $usage;}

  my $K = ReadTranslog($opt_T);

  if(detectChinese($SRC)) {
    WriteChiText($SRC, "$opt_T.Source");
    system("ChiSegmentor.exe $opt_T.Source");
    InsertChiSegments($SRC, "$opt_T.Source"); 
  }
  else {Tokenize($SRC);}
 
  if(detectChinese($TGT)) {
    WriteChiText($TGT, "$opt_T.Target");
    system("ChiSegmentor.exe $opt_T.Target");
    InsertChiSegments($TGT, "$opt_T.Target"); 
  }
  else{ Tokenize($TGT);}

  if (defined($opt_D)) {
    if($SourceLanguage eq '' || $TargetLanguage eq '') { print STDERR "WARNING no language\n";}

    PrintTag("$opt_D.src", $SourceLanguage, $SRC);
    PrintTag("$opt_D.tgt", $TargetLanguage, $TGT);
  }
  else { WriteTranslog($K); }

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

sub detectChinese {
  my ($H) = @_;

  foreach my $cur (keys %{$H}) {
    if(ord($H->{$cur}{'c'}) >= 19968 && ord($H->{$cur}{'c'}) <= 40869) {return 1;}
} }

sub WriteChiText{
  my ($H, $fn) = @_;

  open(FILE, '>:encoding(utf8)', $fn) || die ("cannot open for writing $fn");
  foreach my $cur (keys %{$H}) { print FILE $H->{$cur}{'c'}; } 
  close(FILE);
}

sub  InsertChiSegments{
  my($H, $fn) = @_; 
}

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
  my $number = 1;
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

#print STDERR "Key0: cur:$cur c:>$c< tok:$tok w:>$w< b:>$blank< c+1:>$T->{$cur+1}{'c'}<\n";

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

    elsif($c =~ /[\£\°\~\?\!\"\§\$\%\&\/\(\)\=\{\}\+\*\|\[\]\/\<\>]/) { 
#printf STDERR "Key3: $c\n";
	    $tok =2; }

    # 012'123 => 012 ' 123
    elsif($c =~ /['`’]/ 
         && $w =~ /[^\p{IsAlpha}]$/
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /[^\p{IsAlpha}]/) { 
#printf STDERR "Key4: $c\n";
      $tok = 2;}

    # $'abc => $ ' abc
    elsif($c =~ /['`’]/
         && $w =~ /[^\p{IsAlnum}]/
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /\p{IsAlpha}/) { 
#printf STDERR "Key5: $c\n";
	 $tok = 2;}

    # abc'123 => abc ' 123
    elsif($c =~ /['`’]/
         && $w =~ /[\p{IsAlpha}]$/
         && defined($T->{$cur+1})
         && $T->{$cur+1}{'c'} =~ /[^\p{IsAlpha}]/) { 
#printf STDERR "Key6: $c\n";
	 $tok = 2;}

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
        if($Verbose > 2) { printf STDERR "Tok2: $number\t>$w<\t>$blank<\t>$c<\n";}
        $T->{$start}{'tok'} = $w;
        $T->{$start}{'end'} = $cur -1;
        $T->{$start}{'space'} = $blank;
        $T->{$start}{'wnr'} = $number++;
      }
      if($Verbose > 2) { printf STDERR "Tok2: $number\t>$c<\t><\t><\n";}
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


    if(/<Languages /) {
      if( /source="([^"]*)\"/) {$SourceLanguage = $1;}
      if( /source="([^"]*)\"/) {$TargetLanguage = $1;}
    }

    if(/<Events>/) {$type =1; }
    elsif(/<SourceTextChar>/) {$type =2; }
    elsif(/<TranslationChar>/) {$type =3; }
    elsif(/<FinalTextChar>/) {$type =4; }
	

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
## FinalText Positions
    elsif($type == 4 && /<CharPos/) {
#print STDERR "Final: $_";
      if(/Cursor="([0-9][0-9]*)"/) {$cur =$1;}
      if(/Value="([^"]*)"/)        {$TGT->{$cur}{'c'} = MSunescape($1);}
      if(/X="([0-9][0-9]*)"/)      {$TGT->{$cur}{'x'} = $1;}
      if(/Y="([0-9][0-9]*)"/)      {$TGT->{$cur}{'y'} = $1;}
      if(/Width="([0-9][0-9]*)"/)  {$TGT->{$cur}{'w'} = $1;}
      if(/Height="([0-9][0-9]*)"/) {$TGT->{$cur}{'h'} = $1;}
#if($TGT->{$cur}{'c'} eq "%"){print STDERR '%'. "\t$_";}
#else {printf STDERR "$TGT->{$cur}{'c'}\t$_";}
    } 
    $F->{$n++} = $_;

    if(/<\/FinalText>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/Events>/) {$type =0; }
    if(/<\/SourceTextChar>/) {$type =0; }
    if(/<\/TranslationChar>/) {$type =0; }
    if(/<\/FinalTextChar>/) {$type =0; }
    if(/<\/FinalText>/) {$type =0; }
  }
  close(FILE);

  return $F;
}

sub  WriteTranslog{
  my ($K) = @_;

  my $n=0;
  my $space= '';
  foreach my $f (sort {$a <=> $b} keys %{$K}) { 
    if($K->{$f} =~ /<\/LogFile/) {$n = $f; last;}
  }

  ## Insert Source Token
  $K->{$n++} = " <SourceToken>\n";   
  foreach my $cur (sort {$a <=> $b} keys %{$SRC}) { 
    if(!defined($SRC->{$cur}{'tok'})) { next;}
    if(!defined($SRC->{$cur}{'wnr'})) { 
      print "WriteTranslog: no wnr\n";
      d($SRC->{$cur});
      next;
    }
    if(!defined($SRC->{$cur}{'space'})) { $space = '';}
    else {$space = $SRC->{$cur}{space};}
    $space = escape($space);
    $SRC->{$cur}{tok} = escape($SRC->{$cur}{tok});

    $K->{$n++} = "    <Token id=\"$SRC->{$cur}{wnr}\" cur=\"$cur\" space=\"$space\" tok=\"$SRC->{$cur}{tok}\" />\n";
  }
  $K->{$n++} = " </SourceToken>\n";   

  ## Insert Target Token
  $K->{$n++} = " <FinalToken>\n";   
  foreach my $cur (sort {$a <=> $b} keys %{$TGT}) {
    if(!defined($TGT->{$cur}{'tok'})) { next;}
    if(!defined($TGT->{$cur}{'wnr'})) { 
      print "WriteTranslog: no wnr\n";
      d($TGT->{$cur});
      next;
    }
    if(!defined($TGT->{$cur}{'space'})) { $space = '';}
    else {$space = $TGT->{$cur}{space};}
    $space = escape($space);
    $TGT->{$cur}{tok} = escape($TGT->{$cur}{tok});

    $K->{$n++} = "    <Token id=\"$TGT->{$cur}{wnr}\" cur=\"$cur\" space=\"$space\" tok=\"$TGT->{$cur}{tok}\" />\n";
  }
  $K->{$n++} = " </FinalToken>\n";   
  $K->{$n++} = "</LogFile>\n";   

  ## Write out XML file
  foreach $n (sort {$a <=> $b} keys %{$K}) { print STDOUT $K->{$n}; }
}


## Print DTAG tag format
sub PrintTag {
  my ($fn, $language, $Tag) = @_; 
  my ($f, $s); 

  if(!open(FILE,  ">:encoding(utf8)", $fn)) {
    printf STDERR "cannot open: $fn\n";
    return ;
  }
  if($Verbose){ printf STDERR "Writing: $fn\n";}
  my $w = 0;

  printf FILE "<Text language=\"$language\" >\n";
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
    printf FILE "<W %s>%s</W>\n", $s, escape($Tag->{$f}{'tok'});
  }
  printf FILE "</Text>\n";
  close (FILE);
}

