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
  "Generate atag file from Giza/L1-L2.sent file \n".
  "   Giza2Atag.pl < data/Giza/L1-L2.sent\n".
  "  -A in:  Alignment file <fileroot>.{atag,src,tgt}\n".
  "  -G in:  Giza alignment <filename>\n".
  "     out: <fileroot>.atag \n".
  "Options:\n".
  "  -O out: Write output <filename>.{atag}\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_O $opt_A $opt_G $opt_v $opt_h);

use Getopt::Std;
getopts ('A:O:G:v:t:h');

die $usage if defined($opt_h);

my $Verbose = 0;
my $extension = '';

if (defined($opt_v)) {$Verbose = $opt_v;}

while (<>) {
  chomp;
  my ($atag, $giza, $lang) = split(/\s+\|\|\s+/);

#data/ED12/Translog-II/ED01.xml || data/Giza/ED12_ED01 ||     <Languages source="en" target="da" />

#print "AAA $atag $giza  $lang\n";

  my $A=ReadAtag($atag);
  if(defined($A)) {
    if(ReadAlign("$giza.giza", $A) ==1 ) { PrintAtag("$atag.atag", $atag, $A);}
  }
}

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



sub ReadAlign {
  my ($fn,$A) = @_;
  my ($H, $k, $s, $D, $n);

  if(!open(DATA, "<:encoding(utf8)", $fn)) {
    printf STDERR "ReadAlign: cannot open: $fn\n";
    return 0;
  }

  if($Verbose) {printf STDERR "ReadDtag: %s\n", $fn;}

  $n = 0;
  while(defined($_ = <DATA>)) {
    chomp;
    my ($in, $out) = split(/-/);
    $A->{'align'}{$in+1}{$out+1} ++;
#printf STDERR "$in-$out ";
    $n++;
  }
  return 1;
}
      
#printf STDERR "$_\n";
    
    
###########################################################
# Read src and tgt files
############################################################


sub ReadDTAG {
  my ($fn) = @_;
  my ($x, $k, $s, $D, $n); 

  if(!open(DATA, "<:encoding(utf8)", $fn)) {
    printf STDERR "ReadDTAG: cannot open: $fn\n";
    return undef;
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
    printf STDERR "ReadAtag: cannot open for reading: $fn.atag\n";
    return undef;
  }

  if($Verbose) {printf STDERR "ReadAtag: $fn.atag\n";}
  $extension = "";

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
      $extension = ".giza";
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


sub PrintAtag{
  my ($out, $fn, $A) = @_;

  $fn =~ s/^.*\///g;
  open(FILE, '>:encoding(utf8)', "$out$extension") || die ("cannot open file $out$extension");

print STDERR "Output:$out$extension Tokenfile:$fn\n";

  print FILE "<DTAGalign alignment=\"giza\" >\n";
  print FILE "<alignFile key=\"a\" href=\"$fn.src\" />\n";
  print FILE "<alignFile key=\"b\" href=\"$fn.tgt\" />\n";

  my $type = '';
#d($A->{n}{$n}{Source}{id});
  foreach my $src (sort {$a<=>$b} keys %{$A->{align}}) {
    foreach my $tgt (sort {$a<=>$b} keys %{$A->{align}{$src}}) {
#      print STDERR "<atag out=\"a$src\" type=\"$type\" in=\"b$tgt\" />\n";
      print FILE "<align out=\"a$src\" type=\"$type\" in=\"b$tgt\" />\n";
    }
#print STDERR "XXX\n";
  }
  print FILE "</DTAGalign>\n";
  close(FILE);
}
