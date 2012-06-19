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
  "Produce ProgGraph files: \n".
  "  -T in:  Translog XML file <filename1>\n".
  "  -A in:  Alignment file <filename2>.{atag,src,tgt}\n".
  "  -O out: Write output   <filenamex3>\n".
  "Options:\n".
  "  -t starting token id [1] \n".
  "  -f fixation unit gap \n".
  "  -p production unit gap \n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_f $opt_p $opt_t $opt_O $opt_T $opt_A $opt_v $opt_h);

use Getopt::Std;
getopts ('T:A:O:G:f:p:v:t:h');

die $usage if defined($opt_h);

my $TRANSLOG = {};
my $Verbose = 0;

if (defined($opt_v)) {$Verbose = $opt_v;}

### Read and Tokenize Translog log file
if (defined($opt_T) && defined($opt_A) && defined($opt_O) ) {
  ReadTranslog($opt_T);
  my $A=ReadAtag($opt_A);
  MergeAtag($A);
  PrintTranslog($opt_O, $A);
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

    $s =~ s/([\(\)\\\/])/\\$1/g;
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
        if($fn1 =~ /src$/)    { $lang='Source'; $A->{'a'}{'lang'} = 'Source'; $path .= ".src";}
        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'a'}{'lang'} = 'Final'; $path .= ".tgt";}
      }
## read reference file "b"
      elsif(/key="b"/) { 
        $A->{'b'}{'fn'} =  $fn1;
        if($fn1 =~ /src$/) { $lang='Source'; $A->{'b'}{'lang'} = 'Source'; $path .= ".src";}
        elsif($fn1 =~ /tgt$/) { $lang='Final'; $A->{'b'}{'lang'} = 'Final';$path .= ".tgt";}
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
      $is = $os = '---';

      if(/last="([^"]*)"/) { $A->{'e'}{$n} = $1}
      if(/insign="([^"]*)"/) { $is=$1;}
      if(/outsign="([^"]*)"/){ $os=$1;}

      if(/in="([^"]*)"/) { 
        $K = [split(/\s+/, $1)];
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { 
            $A->{'n'}{$n}{$A->{$1}{'lang'}}{'id'}{$2} ++;
            $A->{'n'}{$n}{$A->{$1}{'lang'}}{'s'}=$is;
          }
#printf STDERR "IN:  %s\t$1\t$2\n", $K->[$i];
        }
      }
      if(/out="([^"]*)"/) { 
        $K = [split(/\s+/, $1)];
        for($i=0; $i <=$#{$K}; $i++) {
          if($K->[$i] =~ /([ab])(\d+)/) { 
            $A->{'n'}{$n}{$A->{$1}{'lang'}}{'id'}{$2} ++;
            $A->{'n'}{$n}{$A->{$1}{'lang'}}{'s'}=$os;
          }
        }
      }
      $n++;
    }
  }
  close (ALIGN);
  return ($A);
}


##########################################################
# Read Translog Logfile
##########################################################

## SourceText Positions
sub ReadTranslog {
  my ($fn) = @_;

  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  if($Verbose){printf STDERR "ReadTranslog: $fn\n";}

  my $n = 0;
  while(defined($_ = <FILE>)) { $TRANSLOG->{$n++} = $_; }
  close(FILE);
  return;
}

##########################################################
# Parse Keystroke Log
##########################################################

sub MergeAtag {
  my ($A) = @_;

  my @L = qw(Final Source);
  foreach my $n (sort {$a<=>$b} keys %{$A->{'n'}}) {
    foreach my $l (@L) {
      foreach my $id (sort {$a<=>$b} keys %{$A->{'n'}{$n}{$l}{'id'}}) {
#    d($A->{'n'}{$n}{$l});
#    d($A->{$l}{'D'}{$id});
        if(!defined($A->{$l}{'D'}{$id})) {
          print STDERR "MergeAtag: Undefined $l: ID:$id\n";
	  next;
        }
        if($A->{'n'}{$n}{$l}{'s'} ne '---' && $A->{'n'}{$n}{$l}{'s'} !~ /$A->{$l}{'D'}{$id}{'tok'}/){ 
          print STDERR "MergeAtag token mismatch $l-$id: atag:$A->{'n'}{$n}{$l}{'s'}\t\ttoken:$A->{$l}{'D'}{$id}{'tok'}\n";
#d($A->{$l}{'D'}{$id});
        }
        $A->{'n'}{$n}{$l}{'id'}{$id} = $A->{$l}{'D'}{$id}{'cur'};
      }
      foreach my $id (sort {$a<=>$b} keys %{$A->{$l}{D}}) {
        if(!defined($A->{n}{$n}{$l}{id})) { print STDERR "MergeAtag: Undefined token: $l: ID:$id\n";}
      }
    }
  }
}

sub PrintTranslog{
  my ($fn, $A) = @_;
  my $m;

  foreach my $i (sort {$b<=>$a} keys %{$TRANSLOG}) { if($TRANSLOG->{$i} =~ /<\/LogFile>/) {$m=$i;last; }}

  my @L = qw(Source Final);
  foreach my $l (@L) {
    $TRANSLOG->{$m++} ="  <$l"."Token>\n";
    foreach my $id (sort {$a<=>$b} keys %{$A->{$l}{'D'}}) {
      $A->{$l}{D}{$id}{tok} =~ s/\\([\(\)\\\/])/$1/g;
      my $tok = MSescape($A->{$l}{D}{$id}{tok});

      my $s = "    <Token id=\"$id\" cur=\"$A->{$l}{D}{$id}{cur}\"";

      if(defined($A->{$l}{D}{$id}{'last'}))   { $s .= " last=\"$A->{$l}{D}{$id}{'last'}\"";}
      if(defined($A->{$l}{D}{$id}{in}))    { $s .= " in=\"$A->{$l}{D}{$id}{in}\"";}
      if(defined($A->{$l}{D}{$id}{out}))   { $s .= " out=\"$A->{$l}{D}{$id}{out}\"";}
      if(defined($A->{$l}{D}{$id}{space})) { my $space =MSescape($A->{$l}{D}{$id}{space}); $s .= " space=\"$space\"";}
      $s .= " tok=\"$tok\" />\n";
      $TRANSLOG->{$m++} = $s;
    }
    $TRANSLOG->{$m++} ="  </$l"."Token>\n";
  }

  $TRANSLOG->{$m++} ="  <Alignment>\n";
  foreach my $n (sort {$a<=>$b} keys %{$A->{'n'}}) {
    my $S = {};
    foreach my $l (@L) {
      my $k=0;
      foreach my $id (sort {$a<=>$b} keys %{$A->{'n'}{$n}{$l}{'id'}}) {
        my $s = MSescape($A->{'n'}{$n}{$l}{'s'});
#	$S->{$l}{$k} = $l."Id=\"$id\" $l=\"$s\"";
	$S->{$l}{$k} = $l."Id=\"$id\" ";
#print STDERR "XXX $S->{$l}{$k}\n";
        if(defined($A->{'e'}{$n})) {$S->{e}{$k} = $A->{'e'}{$n}}
        $k++;
      }
    }
    foreach my $n (sort {$a<=>$b}keys %{$S->{'Source'}}) {
      foreach my $k (sort {$a<=>$b}keys %{$S->{'Final'}}) {
#print STDERR "<align $S->{'Source'}{$n} $S->{'Final'}{$k} />\n";
        my $s = "    <Align $S->{'Source'}{$n} $S->{'Final'}{$k}";
        if(defined($S->{e}{$k})) { $s .= " last=\"$S->{e}{$k}\""}
        $s .= " />\n";
        $TRANSLOG->{$m++} = $s;
      }
    }  
  }
  $TRANSLOG->{$m++} ="  </Alignment>\n";
  $TRANSLOG->{$m++} ="</LogFile>\n";

  open(FILE, '>:encoding(utf8)', $fn) || die ("cannot open file $fn");

  foreach my $k (sort {$a<=>$b} keys %{$TRANSLOG}) { print FILE "$TRANSLOG->{$k}"; }
}
