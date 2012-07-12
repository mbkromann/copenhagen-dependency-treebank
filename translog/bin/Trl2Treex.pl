#!/usr/bin/perl 

use strict;
use warnings;

use Treex::Core;

# Escape characters 
my $map = { map { $_ => 1 } split( //o, "\\<> \t\n\r\f\"" ) };

use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

my $usage =
  "Create Treex file from n Translog-II Event files: \n".
  "  -T in:  Translog XML file <fn1,fn2,...,fn_n>\n".
  "     out: Write treex file to <filename>.treex.gz\n".
  "Options:\n".
  "  -O <filename>: Write output <filename>.treex.gz\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_O $opt_T $opt_v $opt_h);

use Getopt::Std;
getopts ('T:O:v:t:h');

my $Verbose = 0;
my $SourceLanguage = '';
my $TargetLanguage = '';

my $KEY;
my $FIX;
my $TOK;
my $ALN;

## Key mapping
die $usage if defined($opt_h);
die $usage if not defined($opt_T);
die $usage if not defined($opt_O);

my $OutFile = $opt_O;

my $LastSRC;
my $doc = Treex::Core::Document->new;
  my $bundle = $doc->create_bundle;
my $F = [split(/\,/, $opt_T)];

ReadTranslogFile($F->[0]); 
CreateTreex($F->[0]);
$LastSRC = $TOK->{src};

for (my $i= 1; $i<= $#{$F}; $i++) {
  $KEY = $FIX = $TOK = $ALN = undef;

  ReadTranslogFile($F->[$i]); 
  if(CheckSRCToken($LastSRC, $TOK->{src})) {
    print STDERR "ReadTranslog: TokenDiff $F->[0], $F->[$i]\n";
    next;
  }
  $TOK->{src} = undef;
  CreateTreex($F->[$i]);
}

$doc->save("$OutFile.treex.gz");

#ReadTranslog($opt_T);
#CreateTreex($OutFile);

exit;


##########################################################
# Read Translog Logfile
##########################################################

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

sub escape {
  my ($in) = @_;
#print	 STDERR "in: $in\n";
  $in =~ s/(.)/exists($map->{$1})?sprintf('\\%04x',ord($1)):$1/egos;
  return $in;
}

sub unescape {
  my ($in) = @_;
  $in =~ s/\\([0-9a-f]{4})/sprintf('%c',hex($1))/egos;
  return $in;
}


## SourceText Positions
sub CheckSRCToken {
  my ($T1, $T2) = @_;

  foreach my $cur (sort {$a <=> $b} keys %{$T1}) { 
    if(!defined($T2->{$cur})) { print STDERR "CheckSRCToken: undefined cursor $cur\n"; return 1;}
    if($T1->{$cur}{tok} ne $T2->{$cur}{tok}) { print STDERR "CheckSRCToken: unequal token $T1->{$cur}{tok}\t$T2->{$cur}{tok}\n"; return 1;}
  }
  return 0;
}



## SourceText Positions
sub ReadTranslogFile {
  my ($fn) = @_;
  my ($type, $time, $cur);

  open(FILE, '<:encoding(utf8)', $fn) || die ("cannot open file $fn");
  if($Verbose) {printf STDERR "ReadTranslog Reading: $fn\n";}
#  printf STDERR "ReadTranslog Reading: $fn\n";

  $type = 0;
  while(defined($_ = <FILE>)) {
#printf STDERR "Translog: %s\n",  $_;

    if(/<Languages/) {
      if(/source="([^"]*)"/) {$SourceLanguage =$1;}
      if(/target="([^"]*)"/) {$TargetLanguage =$1;}
    }
    if(/<Events>/) {$type =1; }
    elsif(/<SourceTextChar>/) {$type =2; }
    elsif(/<TranslationChar>/) {$type =3; }
    elsif(/<FinalTextChar>/) {$type =4; }
    elsif(/<FinalText>/)   {$type =5; }
    elsif(/<Alignment>/)   {$type =6; }
    elsif(/<SourceToken>/){$type =7; }
    elsif(/<FinalToken>/) {$type =8; }
    elsif(/<Fixations>/) {$type =9; }
    elsif(/<Modifications>/) {$type =10; }
	
    if($type == 9 && /<Fix/) {
#printf STDERR "Translog: %s\n",  $_;
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/win="([0-9][0-9]*)"/)  {$FIX->{$time}{'win'} = $1;}
      if(/dur="([0-9][0-9]*)"/)  {$FIX->{$time}{'dur'} = $1;}
      if(/cur="([-0-9][0-9]*)"/) {$FIX->{$time}{'cur'} = $1;}
      if(/sid="([^"]*)"/)        {$FIX->{$time}{'sid'} = $1;}
      if(/tid="([^"]*)"/)        {$FIX->{$time}{'tid'} = $1;}

    }
    elsif($type == 10 && /<Mod /) {  
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/cur="([0-9][0-9]*)"/)  {$KEY->{$time}{'cur'} = $1;}
      if(/chr="([^"]*)"/)  {$KEY->{$time}{'chr'} = MSunescape($1);}
#      if(/chr="([^"]*)"/)  {$KEY->{$time}{'chr'} = $1;}
      if(/type="([^"]*)"/) {$KEY->{$time}{'type'} = $1;}
      if(/sid="([^"]*)"/)  {$KEY->{$time}{'sid'} = $1;}
      if(/tid="([^"]*)"/)  {$KEY->{$time}{'tid'} = $1;}
      if($KEY->{$time}{'sid'} eq '') { $KEY->{$time}{'sid'} = "-1";}
      if($KEY->{$time}{'tid'} eq '') { $KEY->{$time}{'tid'} = "-1";}
#d($KEY->{$time});
    }

    elsif($type == 6 && /<Align /) {
#print STDERR "ALIGN: $_";
      my ($si, $ti, $ss, $ts);
      if(/sid="([^"]*)"/)       {$si =$1;}
      if(/tid="([^"]*)"/)       {$ti =$1;}
      $ALN->{'tid'}{$ti}{'sid'}{$si} = $ss;
    }
    elsif($type == 7 && /<Token/) {
      if(/cur="([0-9][0-9]*)"/) {$cur =$1;}
#      if(/tok="([^"]*)"/)   {$TOK->{src}{$cur}{tok} = $1;}
      if(/last="([^"]*)"/)  {$TOK->{src}{$cur}{last} = $1;}
      if(/tok="([^"]*)"/)   {$TOK->{src}{$cur}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$TOK->{src}{$cur}{space} = MSunescape($1);}
      if(/out="([^"]*)"/)   {$TOK->{src}{$cur}{out} = $1;}
      if(/in="([^"]*)"/)    {$TOK->{src}{$cur}{in} = $1;}
      if(/id="([^"]*)"/)    {$TOK->{src}{$cur}{id} = $1;}
    }

    elsif($type == 8 && /<Token/) {
      if(/cur="([0-9][0-9]*)"/) {$cur =$1;}
#      if(/tok="([^"]*)"/)   {$TOK->{fin}{$cur}{tok} = $1;}
#      if(/space="([^"]*)"/) {$TOK->{fin}{$cur}{space} = $1;}
      if(/last="([^"]*)"/)  {$TOK->{src}{$cur}{last} = $1;}
      if(/tok="([^"]*)"/)   {$TOK->{fin}{$cur}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$TOK->{fin}{$cur}{space} = MSunescape($1);}
      if(/out="([^"]*)"/)   {$TOK->{fin}{$cur}{out} = $1;}
      if(/in="([^"]*)"/)    {$TOK->{fin}{$cur}{in} = $1;}
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
    if(/<\/Modifications>/) {$type =0; }
    if(/<\/Fixations>/) {$type =0; }
  }
  close(FILE);

#foreach my $f (sort {$a <=> $b} keys %{$TEXT}) { print STDERR "$TEXT->{$f}{c}" }
#printf STDERR "\n";

}

################################################
#  PRINTING
################################################

sub CreateTreex {
  my ($fn) = @_;
  my $ord;

  if($TargetLanguage eq '' || $SourceLanguage eq '') {
    print STDERR "$fn Undefined Languages\n";
    exit 1;
  }

  $fn =~ s/^.*\///;
  $fn =~ s/.Event.xml//;
  $fn =~ s/[._]//;

  my $zone_tgt = $bundle->create_zone($TargetLanguage, $fn);
  my $root_tgt = $zone_tgt->create_atree;
  $root_tgt->wild->{SourceLanguage} = $SourceLanguage;


  my $sent = 1;
  if(defined($TOK->{src})) { 
    my $zone_src = $bundle->create_zone($SourceLanguage);
    my $root_src = $zone_src->create_atree;

    $root_src->wild->{SourceLanguage} = $SourceLanguage;
    $bundle->wild->{SourceLanguage} = $SourceLanguage;

    $sent = 1;

    foreach my $cur (sort {$a <=> $b} keys %{$TOK->{src}}) {
      $ord++;
      my $node = $root_src->create_child(ord=>$ord);
      if(defined($TOK->{src}{$cur}{last}) && defined($TOK->{src}{$cur}{last}) eq "sent") { $sent ++;}
  
      $node->set_form($TOK->{src}{$cur}{tok});
      $node->set_id("src_$TOK->{src}{$cur}{id}");
      $node->wild->{linenumber} = $TOK->{src}{$cur}{id};
      $node->wild->{sent_number} = $sent;
      foreach my $attr (keys %{$TOK->{src}{$cur}}) { $node->wild->{$attr} = $TOK->{src}{$cur}{$attr};}
    }
  }


  foreach my $t (keys %{$FIX}) {

    if($FIX->{$t}{win} != 1 && $FIX->{$t}{win} != 2) {next;}

    foreach my $attr (keys %{$FIX->{$t}}) { 
      if($attr eq 'tid') { $root_tgt->wild->{FIX}{$t}{tid} = $fn."_".$FIX->{$t}{tid};}
      elsif($attr eq 'sid') { $root_tgt->wild->{FIX}{$t}{sid} = "src_$FIX->{$t}{sid}";}
      else { $root_tgt->wild->{FIX}{$t}{$attr} = $FIX->{$t}{$attr};}
    }
  }

  foreach my $t (keys %{$KEY}) {
    if(!defined($KEY->{$t}{'tid'})) { 
      print STDERR "$fn\t KEY id undefined: $t\n";
      d($KEY->{$t});
      next;
    }
#print STDERR "XXXXXX $s\n";
#d($KEY->{$t});

    foreach my $attr (keys %{$KEY->{$t}}) { 
      if($attr eq 'tid') { $root_tgt->wild->{KEY}{$t}{tid} = $fn."_".$KEY->{$t}{tid};}
      elsif($attr eq 'sid') { $root_tgt->wild->{KEY}{$t}{sid} = "src_$KEY->{$t}{sid}";}
      else { $root_tgt->wild->{KEY}{$t}{$attr} = $KEY->{$t}{$attr};}
    }
  }

  $sent = 1;
  
  foreach my $cur (sort {$a <=> $b} keys %{$TOK->{fin}}) {
    $ord++;
    my $node = $root_tgt->create_child(ord=>$ord);
    if(defined($TOK->{fin}{$cur}{last}) && defined($TOK->{fin}{$cur}{last}) eq "sent") { $sent ++;}

    $node->set_form($TOK->{fin}{$cur}{tok});
    $node->set_id($fn."_".$TOK->{fin}{$cur}{id});
    $node->wild->{linenumber} = $TOK->{fin}{$cur}{id};
    $node->wild->{sent_number} = $sent;
    foreach my $attr (keys %{$TOK->{fin}{$cur}}) { $node->wild->{$attr} = $TOK->{fin}{$cur}{$attr};}

    my $tid = $TOK->{fin}{$cur}{id};

#print STDERR "TGT tgt: $TOK->{fin}{$cur}{id} $TOK->{fin}{$cur}{tok} $tid\n";
#d($ALN->{tid}{$tid});

    if(!defined($ALN->{tid}{$tid})) {next;}
    foreach my $sid (keys %{$ALN->{tid}{$tid}{sid}}) {
#printf STDERR "TGT: $TOK->{fin}{$cur}{id} $cur a:$sid node:%s\n", $doc->get_node_by_id("src_$sid");
      $node->add_aligned_node($doc->get_node_by_id("src_$sid"), 'alignment');
    }
  }
#  $doc->save("$fn.treex.gz");
}

