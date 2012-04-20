#!/usr/bin/perl 

use strict;
use warnings;

use Treex::Core;

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

my $Verbose = 0;
my $fn;

my $KEY;
my $FIX;
my $TOK;
my $ALN;

## Key mapping
die $usage if defined($opt_h);
die $usage if not defined($opt_T);

if(defined($opt_O)) { $fn = $opt_O;}
else {$fn = $opt_T; $fn =~ s/.xml$//;}

ReadTranslog($opt_T);
CreateTreex($fn);

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
      if(/cur="([0-9][0-9]*)"/)  {$FIX->{$time}{'cur'} = $1;}
      if(/id="([0-9][0-9]*)"/)   {$FIX->{$time}{'id'} = $1;}

    }
    elsif($type == 10 && /<Mod /) {  
      if(/time="([0-9][0-9]*)"/) {$time =$1;}
      if(/cur="([0-9][0-9]*)"/)  {$KEY->{$time}{'cur'} = $1;}
#      if(/chr="([^"]*)"/)  {$KEY->{$time}{'chr'} = MSunescape($1);}
      if(/chr="([^"]*)"/)  {$KEY->{$time}{'chr'} = $1;}
      if(/type="([^"]*)"/) {$KEY->{$time}{'type'} = $1;}
      if(/sid="([0-9][0-9]*)"/)  {$KEY->{$time}{'sid'} = $1;}
      if(/id="([-0-9][0-9]*)"/)  {$KEY->{$time}{'id'} = $1;}
    }

    elsif($type == 6 && /<Align /) {
#print STDERR "ALIGN: $_";
      my ($si, $ti, $ss, $ts);
      if(/SourceId="([^\"]*)"/) {$si =$1;}
#      if(/Source="([^\"]*)"/)    {$ss =MSunescape($1);}
      if(/Source="([^\"]*)"/)    {$ss =$1;}
      if(/FinalId="([^\"]*)"/)  {$ti =$1;}
      if(/Final="([^\"]*)"/)     {$ts =$1;}
      $ALN->{'tid'}{$ti}{'sid'}{$si} = $ss;
    }
    elsif($type == 7 && /<Token/) {
      if(/cur="([0-9][0-9]*)"/) {$cur =$1;}
#      if(/tok="([^"]*)"/)   {$TOK->{src}{$cur}{tok} = MSunescape($1);}
#      if(/space="([^"]*)"/) {$TOK->{src}{$cur}{space} = MSunescape($1);}
      if(/tok="([^"]*)"/)   {$TOK->{src}{$cur}{tok} = $1;}
      if(/space="([^"]*)"/) {$TOK->{src}{$cur}{space} = $1;}
      if(/id="([^"]*)"/)    {$TOK->{src}{$cur}{id} = $1;}
    }

    elsif($type == 8 && /<Token/) {
      if(/cur="([0-9][0-9]*)"/) {$cur =$1;}
#      if(/tok="([^"]*)"/)   {$TOK->{fin}{$cur}{tok} = MSunescape($1);}
#      if(/space="([^"]*)"/) {$TOK->{fin}{$cur}{space} = MSunescape($1);}
      if(/tok="([^"]*)"/)   {$TOK->{fin}{$cur}{tok} = $1;}
      if(/space="([^"]*)"/) {$TOK->{fin}{$cur}{space} = $1;}
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

  return $KeyLog;
}

################################################
#  PRINTING
################################################

sub CreateTreex {
  my ($fn) = @_;
  my $ord;

  my $doc = Treex::Core::Document->new;
  my $bundle = $doc->create_bundle;
  my $zone_src = $bundle->create_zone('en');
  my $zone_tgt = $bundle->create_zone('da');
  my $root_src = $zone_src->create_atree;
  my $root_tgt = $zone_tgt->create_atree;

  foreach my $t (keys %{$FIX}) {
    my $id=0;

    if(!defined($FIX->{$t}{id})) { 
      print STDERR "$fn FIX Undefined $t\n";
      d($FIX->{$t});
      next;
    }
    if($FIX->{$t}{win} == 1) {$id="src_".$FIX->{$t}{id};}
    elsif($FIX->{$t}{win} == 2) {$id="tgt_".$FIX->{$t}{id};}
    else {next;}

    $doc->wild->{FIX}{$t}{win}  = $FIX->{$t}{'w'};
    $doc->wild->{FIX}{$t}{dur}  = $FIX->{$t}{'d'};
    $doc->wild->{FIX}{$t}{cur}  = $FIX->{$t}{'c'};
    $doc->wild->{FIX}{$t}{id}   = $id;
    $doc->wild->{FIX}{$t}{unit} = $FIX->{$t}{'fu'};
  }

  foreach my $t (keys %{$KEY}) {
    if(!defined($KEY->{$t}{'id'})) { 
      print STDERR "$fn\t KEY id undefined: $t\n";
      d($KEY->{$t});
      next;
    }
    if(defined($ALN->{'tid'}) && 
       defined($ALN->{'tid'}{$KEY->{$t}{'id'}})) {
      foreach my $sid (sort  {$a <=> $b} keys %{$ALN->{'tid'}{$KEY->{$t}{'id'}}{'sid'}}) {
        $doc->wild->{KEY}{$t}{sid}{"src_$sid"} ++;
      }
    }
#print STDERR "XXXXXX $s\n";
#d($KEY->{$t});

    $doc->wild->{KEY}{$t}{char} = $KEY->{$t}{'chr'};
    $doc->wild->{KEY}{$t}{type} = $KEY->{$t}{'type'};
    $doc->wild->{KEY}{$t}{cur}  = $KEY->{$t}{'cur'};
    $doc->wild->{KEY}{$t}{id} = "tgt_$KEY->{$t}{id}";
  }

  foreach my $cur (sort {$a <=> $b} keys %{$TOK->{src}}) {
    $ord++;
    my $node = $root_src->create_child(ord=>$ord);

    $node->set_form($TOK->{src}{$cur}{tok});
    $node->set_id("src_$TOK->{src}{$cur}{id}");
    $node->wild->{linenumber} = $TOK->{src}{$cur}{id};
#d($node->wild);
  }

  foreach my $cur (sort {$a <=> $b} keys %{$TOK->{fin}}) {
    $ord++;
    my $node = $root_tgt->create_child(ord=>$ord);

    $node->set_form($TOK->{fin}{$cur}{tok});
    $node->set_id("tgt_$TOK->{fin}{$cur}{id}");
    $node->wild->{linenumber} = $TOK->{fin}{$cur}{id};

#print STDERR "TGT tgt: $TGT->{$cur}{id} $TGT->{$cur}{tok} $cur\n";

    if(!defined($ALN->{tcur}{$cur})) {next;}
    foreach my $sid (keys %{$ALN->{tcur}{$cur}{sid}}) {
#print STDERR "TGT: $TOK->{fin}{$cur}{id} $cur a:$sid\n";
#print STDERR "TGT: $TGT->{$cur}{id} $cur sid:$sid\t$TGT->{$cur}{tok}\ta:$ALN->{t}{$cur}{sid}{$sid}\n";
#    d($ALN->{t}{$TGT->{$cur}{id}}{sid});
      $node->add_aligned_node($doc->get_node_by_id("src_$sid"));
    }
  }
  $doc->save("$fn.treex.gz");
}

