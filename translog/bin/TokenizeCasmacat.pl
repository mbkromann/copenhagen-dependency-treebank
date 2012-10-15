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
  "  -D out: Write in {.src,.tgt} file\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_D $opt_T $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:D:v:h');

die $usage if defined($opt_h);

my $Verbose = 0;
my $SourceLanguage = '';
my $TargetLanguage = '';

if (defined($opt_v)) {$Verbose = $opt_v;}
if (!defined($opt_T)) {die $usage;}
if (!defined($opt_D)) {die $usage;}

  my $X=ReadTranslog($opt_T);
  my $T=Text2Chars($X);
  if(defined($T->{1})) {
    foreach my $seg (keys %{$T->{1}}) { Tokenize($T->{1}{$seg});}
  }
#  if(defined($T->{2})) {Tokenize($T->{2});}
  if(defined($T->{3})) {
    foreach my $seg (keys %{$T->{1}}) { Tokenize($T->{3}{$seg});}
  }
  if($SourceLanguage eq '' || $TargetLanguage eq '') { print STDERR "WARNING no language\n";}

  PrintTag("$opt_D.src", $SourceLanguage, $T->{1});
  PrintTag("$opt_D.tgt", $TargetLanguage, $T->{3});

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

sub MSTokEscape {
  my ($in) = @_;

  $in =~ s/\&/&amp;/g;
  $in =~ s/\>/&gt;/g;
  $in =~ s/\</&lt;/g;
#  $in =~ s/\n/&#xA;/g;
#  $in =~ s/\r/&#xD;/g;
#  $in =~ s/\t/&#x9;/g;
#  $in =~ s/"/&quot;/g;
#  $in =~ s/ /&nbsp;/g;
  return $in;
}


## escape for R tables
sub Rescape {
  my ($in) = @_;

  $in =~ s/([ \t\n\r\f\#])/_/g;
  $in =~ s/(['"])/\\$1/g;
  return $in;
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
  my $seg='noSegment';

#print STDERR "DUDUDUD\n";
#d($T);
  foreach $cur (sort {$a <=> $b} keys %{$T}) {
    if($start == -1) {$start = $cur;}

    $c = $T->{$cur}{c};

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

    elsif($c =~ /[\£\°\~\¿\?\!\¡\"\§\$\%\&\/\(\)\=\{\}\+\*\|\[\]\/\<\>]/) { 
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

    if($tok == 0 && $seg ne 'noSegment' && $seg ne $T->{$cur}{segId}) {$tok = 3;}

    $seg = $T->{$cur}{segId};


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

  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");

  my $type = 0;
  my $T;
  my $seg = 0;
  # segments may span several lines, so we store parts in inSegment
  my $inSegment = "";
  my $segmentID = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;


    if(/<Languages /) {
      if(/Source="([^"]*)\"/) {$SourceLanguage = $1;}
      if(/Target="([^"]*)\"/) {$TargetLanguage = $1;}
    }

    elsif(/<SourceText[ >]/) {$type =1; $seg=0;}
    elsif(/<TargetText[ >]/) {$type =2; $seg=0;}
    elsif(/<FinalText[ >]/)  {$type =3; $seg=0;}
	
    if(($type == 1 || $type == 2 || $type == 3)  && (/<seg/i || length $inSegment > 0)) {
	if(/id="([^"]*)/i){
	    $segmentID = $1;
	}
	# save segment if it ends in this line
	if( /([^>]*)<\/seg/i){
	    $inSegment .= $1;
	    $inSegment =~ s/\s*\n\s*/ /g;
	    $T->{$seg}{$type}{text} = $inSegment;
	    $T->{$seg}{$type}{id} = $segmentID;
	    $inSegment = "";
	    $seg ++;
	}
	# otherwise store string after possible start tag
	elsif(/([^>]+)$/){
	    $inSegment .= $1;
	}
#print STDERR "Source: $seg\t$id\t$text\n";
    }

    if(/<\/SourceText/) {$type =0; }
    if(/<\/TargetText/) {$type =0; }
    if(/<\/FinalText/) {$type =0 }
  }
  close(FILE);
  return $T;
}

sub  Text2Chars{
  my ($T) = @_;
  my $K = {};

  foreach my $seg (sort {$a <=> $b} keys %{$T}) {
    foreach my $type (sort {$a <=> $b} keys %{$T->{$seg}}) {
#print STDERR "TTT3 $type $T->{$seg}{$type}{text}\n";
      my $S = [split(//, $T->{$seg}{$type}{text})];
      for (my $i = 0; $i<=$#{$S}; $i++) {
         $K->{$type}{$seg}{$i}{'c'} = $S->[$i];
         $K->{$type}{$seg}{$i}{'segId'} = $T->{$seg}{$type}{id};
#print STDERR "TTT4 $seg*1000+$i\n";
#d($K->{$type}{$seg*1000+$i});
      } 
    }
  }
  return $K;
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
  my $id=1;
  foreach my $seg (sort {$a<=>$b} keys %{$Tag}) {
    foreach $f (sort {$a <=> $b} keys %{$Tag->{$seg}}) {
#printf STDERR "Tag: $_";
      if(!defined($Tag->{$seg}{$f}{'tok'})) { next;}
      $s = '';
      if(defined($Tag->{$seg}{$f}{'end'}) && defined($Tag->{$seg}{$f}{'x'})) {
#printf STDERR "Tag: $f  $Tag->{$seg}{$f}{'end'}\t$Tag->{$seg}{$f}{'tok'}\n";
        $w = $Tag->{$seg}{$Tag->{$f}{$seg}{'end'}}{'x'} + $Tag->{$Tag->{$seg}{$f}{'end'}}{'w'} - $Tag->{$seg}{$f}{'x'};
      }

      $s .= "cur=\"$f\" id=\"$id\"";
      $id++;
      if(defined($Tag->{$seg}{$f}{'segId'})) { $s .= " segId=\"$Tag->{$seg}{$f}{'segId'}\""; }
#print STDERR "XXXX\n";
#d($Tag->{$seg}{$f});
      #if(defined($Tag->{$seg}{$f}{'space'}) && $Tag->{$seg}{$f}{'space'} ne "") {$s .= " space=\"$Tag->{$seg}{$f}{'space'}\"";}
      if(defined($Tag->{$seg}{$f}{'space'}) && $Tag->{$seg}{$f}{'space'} ne "") {
         my $e = MSescape($Tag->{$seg}{$f}{'space'});
         $s .= " space=\"$e\"";
      }
      printf FILE "<W %s>%s</W>\n", $s, MSTokEscape($Tag->{$seg}{$f}{'tok'});
    }
  }
  printf FILE "</Text>\n";
  close (FILE);
}

