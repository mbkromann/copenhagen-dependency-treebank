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
  "Write tokenized sentences into : \n".
  "  -A in: Alignment file <filename>.{atag,src,tgt}\n".
  "  -S in: Sentence Alignment <filename>\n".
  "  -O out: Write output   <filename>.{atag,src,tgt}\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_S $opt_O $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('A:O:S:v:t:h');

die $usage if defined($opt_h);
die $usage if not defined($opt_A);
die $usage if not defined($opt_S);
die $usage if not defined($opt_O);

my $Verbose = 0;

if (defined($opt_v)) {$Verbose = $opt_v;}

  my $A=ReadAtag($opt_A);
  my $S=ReadSentences($opt_S);
  my $B=MapBoundary($A, $S);
  PrintTokens($opt_A, $opt_O, $A, $B);

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
  $in =~ s/ /&nbsp;/g;
  return $in;
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

  if($Verbose) {printf STDERR "ReadDtag: %s\n", $fn;}

  $n = 1;
  while(defined($_ = <DATA>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;
#printf STDERR "$_\n";

    if(!/<W ([^>]*)>([^<]*)/) {next;} 
    $x = $1;
    $s = unescape($2);
    if(/id="([^"])"/ && $1 != $n) {
      printf STDERR "Read $fn: unmatching n:$n and id:$1\n";
      $n=$1;
    }

    $s =~ s/([\(\)\\\/?.\|])/\\$1/g;
    $D->{$n}{'tok'}=$s;
#printf STDERR "\tvalue:$2\t";
    $x =~ s/\s*([^=]*)\s*=\s*"([^"]*)\s*"/AttrVal($D, $n, $1, $2)/eg;
    if(defined($D->{$n}{id}) && $D->{$n}{id} != $n)  {
      print STDERR "ReadDTAG: IDs $fn: n:$n\tid:$D->{$n}{id}\n";
    }
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
  $D->{$n}{$attr}=unescape($val);
}


sub ReadAtag {
  my ($fn) = @_;
  my ($A, $K, $fn1, $i, $is, $os, $lang, $n); 

  if(!open(ALIGN,  "<:encoding(utf8)", "$fn.atag")) {
    printf STDERR "cannot open for reading: $fn.atag\n";
    exit 1;
  }

  if($Verbose) {printf STDERR "ReadAtag: $fn.atag\n";}

## read alignment file
  $n = 0;
  while(defined($_ = <ALIGN>)) {
    if($_ =~ /^\s*$/) {next;}
    if($_ =~ /^#/) {next;}
    chomp;

#printf STDERR "Alignment %s\n", $_;
## read aligned files
    if(/<alignFile/) {
      my $path = $fn;
      if(/href="([^"]*)"/) { $fn1 = $1;}

## read reference file "a"
      if(/key="a"/) { 
        $A->{'a'}{'fn'} =  $fn1;
        if($fn1 =~ /src$/)    { $lang='Source'; $A->{'a'} = 'Source'; $path .= ".src";}
        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'a'} = 'Final'; $path .= ".tgt";}

#        if($fn1 =~ /src$/)    { $lang='Source'; $A->{'Source'} = 'a'; $path .= ".src";}
#        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'Final'} = 'a'; $path .= ".tgt";}
      }
## read reference file "b"
      elsif(/key="b"/) { 
        $A->{'b'}{'fn'} =  $fn1;
        if($fn1 =~ /src$/) { $lang='Source'; $A->{'b'} = 'Source'; $path .= ".src";}
        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'b'} = 'Final';$path .= ".tgt";}

#        if($fn1 =~ /src$/) { $lang='Source'; $A->{'Source'} = 'b'; $path .= ".src";}
#        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'Final'} = 'b';$path .= ".tgt";}
      }
      else {printf STDERR "Alignment wrong %s\n", $_;}

#      $A->{$lang}{'D'} =  ReadDTAG("$path/$fn1"); 
      $A->{$lang}{'D'} =  ReadDTAG("$path"); 
  
      next;
    }

    if(/<align /) {
#printf STDERR "ALN: $_\n";
      if(/in="([^"]*)"/) { $is=$1;}
      if(/out="([^"]*)"/){ $os=$1;}

      ## aligned to itself
      if($is eq $os) {next;}

      if(/insign="([^"]*)"/) { $is=$1;}
      if(/outsign="([^"]*)"/){ $os=$1;}

      if(/in="([^"]*)"/) { 
        $K = [split(/\s+/, $1)];
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { 
            $A->{'n'}{$n}{$A->{$1}}{'id'}{$2} ++;
            $A->{'n'}{$n}{$A->{$1}}{'s'}=$is;
          }
#printf STDERR "IN:  %s\t$1\t$2\n", $K->[$i];
        }
      }
      if(/out="([^"]*)"/) { 
        $K = [split(/\s+/, $1)];
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { 
            $A->{'n'}{$n}{$A->{$1}}{'id'}{$2} ++;
            $A->{'n'}{$n}{$A->{$1}}{'s'}=$os;
          }
        }
      }
      $n++;
    }
  }
  close (ALIGN);
  return ($A);
}

sub ReadSentences {
  my ($fn) = @_;
  my ($S);

  if(!open(SENT,  "<:encoding(utf8)", "$fn")) {
    printf STDERR "cannot open for reading: $fn\n";
    exit 1;
  }

  my $n = 0;
  while(defined($_ = <SENT>)) {
    chomp;
    ($S->{$n}{Source}, $S->{$n}{Final}, $S->{$n}{Score}) = split(/\t/, lc($_));
#printf STDERR "MapBoundary Source $n\n%s\n%s\n%s\n", $S->{$n}{Source}, $S->{$n}{Final}, $S->{$n}{Score};
    $n++;
  }
  close(SENT);
  return $S;
}


sub MapBoundary {
  my ($A, $S) = @_;
  my $B = {};

  my $n=0;
  foreach my $id (sort {$a<=>$b} keys %{$A->{Source}{'D'}}) {
    my $tok = lc($A->{Source}{D}{$id}{tok});
#printf STDERR "MapBoundary Source $id $tok\t|||\t%s\n", $S->{$n}{Source};
    if($S->{$n}{Source} !~ s/^\s*$tok\s*//) {printf STDERR "MapBoundary unmapped Source: $id $tok\t|||\t%s\n",  $S->{$n}{Source};}
    while(defined($S->{$n}) && $S->{$n}{Source} =~ s/^\s*~~~\s*//) { $B->{Source}{$id} ++; }
    while(defined($S->{$n}) && $S->{$n}{Source} eq '') {$B->{Source}{$id}++;  $B->{A}{Source}{$id} ++; $n++;}
  }

  $n=0;
  foreach my $id (sort {$a<=>$b} keys %{$A->{Final}{'D'}}) {
    my $tok = lc($A->{Final}{D}{$id}{tok});
#printf STDERR "MapBoundary Final $id $tok |||\t%s\n", $S->{$n}{Final};
    if($S->{$n}{Final} !~ s/^\s*$tok\s*//) {printf STDERR "MapBoundary unmapped Final: $id $tok\t|||\t%s\n",  $S->{$n}{Final};}
    while(defined($S->{$n}) && $S->{$n}{Final} =~ s/^\s*~~~\s*//) { $B->{Final}{$id} ++; }
    while(defined($S->{$n}) && $S->{$n}{Final} eq '') {$B->{Final}{$id}++; $B->{A}{Final}{$id} ++; $n++;}
#printf STDERR "MapBoundary Final $id $tok |||\t%s\n", $S->{$n}{Final};
  }
  return $B;
}

sub PrintTokens{
  my ($fn, $w, $A, $B) = @_;
  my $lineBreak=1;

  if(!open(ALIGN,  "<:encoding(utf8)", "$fn.atag")) {
    printf STDERR "cannot open for reading: $fn.atag\n";
    exit 1;
  }
  if(!open(ALIGN1,  ">:encoding(utf8)", "$w.atag")) {
    printf STDERR "cannot open for writing: $w.atag\n";
    exit 1;
  }

#printf STDERR "Source\n";
#d($B->{Source});
#printf STDERR "Final\n";
#d($B->{Final});
#printf STDERR "BoundF\n";
#d($B->{A});
  my ($out, $in,  $inAB, $outAB, $IN, $OUT);
  $out=$in=$inAB=$outAB = '';
  while(defined($_ = <ALIGN>)) {
    $out=$in=$inAB=$outAB = '';
    if(/out="([^"]*)"/) {$out = $1}
    if(/in="([^"]*)"/) {$in = $1}

    if($out ne '' && $in ne '') {
        $IN=$OUT={};

        if($in  =~ /([ab])/) { $inAB = $1;  $IN = { map { $_ => 1 } split( /[ab]/, $in ) };}
        if($out =~ /([ab])/) { $outAB = $1; $OUT = { map { $_ => 1 } split( /[ab]/, $out ) };}

#d($B->{A}{$A->{$inAB}});
#d($B->{A}{$A->{$outAB}});
#d($IN);
#d($OUT);
#d($A->{$inAB});
#d($A->{$outAB});

        my $k1 = -1;
        my $k2 = -1;
        foreach my $k (keys %{$IN}) {if (defined($B->{A}{$A->{$inAB}}{$k})){ $k1=$k; last;}  }
        foreach my $k (keys %{$OUT}) {if (defined($B->{A}{$A->{$outAB}}{$k})){ $k2=$k; last;}  }
    
        if($k1 >=0 && $k2 >= 0) { s/\/>/last=\"align\" \/>/; $B->{A}{$A->{$inAB}}{$k1} = 0; $B->{A}{$A->{$outAB}}{$k2}=0;}
    }

    print ALIGN1 "$_";
  }
  close (ALIGN);
  close (ALIGN1);

  if($inAB ne '') {
    foreach my $l (keys %{$B->{A}}) {
      foreach my $k (keys %{$B->{A}{$l}}) {
          if($B->{A}{$l}{$k} != 0) { printf STDERR "PrintTokens: Warning unmatching alignment: $l:$k\n";}
    } }    
  }

  if(!open(SRC,  "<:encoding(utf8)", "$fn.src")) {
    printf STDERR "cannot open for reading: $fn.src\n";
    exit 1;
  }
  if(!open(SRC1,  ">:encoding(utf8)", "$w.src")) {
    printf STDERR "cannot open for reading: $w.src\n";
    exit 1;
  }

  while(defined($_ = <SRC>)) {
    my $id = '';
    if(/id="([^"]*)"/) {$id = $1}

# print STDERR "XXXX: $id\n"; 
# d($B->{Source}{$id});

    if($id ne '') { if (defined($B->{Source}{$id})){ s/id="/last=\"sent\" id="/; } }
#    if($id ne '') { if (defined($B->{Source}{$id})){print STDERR "Source: $id\n"; d($B->{Source}{$id});}}

    print SRC1 "$_";
  }
  close (SRC);
  close (SRC1);

  if(!open(TGT,  "<:encoding(utf8)", "$fn.tgt")) {
    printf STDERR "cannot open for reading: $fn.tgt\n";
    exit 1;
  }
  if(!open(TGT1,  ">:encoding(utf8)", "$w.tgt")) {
    printf STDERR "cannot open for reading: $w.tgt\n";
    exit 1;
  }

  while(defined($_ = <TGT>)) {
    my $id = '';
    if(/id="([^"]*)"/) {$id = $1}

    if($id ne '') { if (defined($B->{Final}{$id})){ s/id="/last=\"sent\" id="/; } }

    print TGT1 "$_";
  }
  close (TGT);
  close (TGT1);



}
