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
my $first_bundle = $bundle;
my @unaligned_nodes; 

my $F = [split(/\,/, $opt_T)];

print STDERR "Trl2Treex.pl: creating source $F->[1]\n";
ReadTranslogFile($F->[0]); 
FakeSentBoundary();
CreateSourceZone($F->[0]);
AppendTargetZone($F->[0]);
$LastSRC = $TOK->{src};

for (my $i= 1; $i<= $#{$F}; $i++) {
  $KEY = $FIX = $TOK = $ALN = undef;

  ReadTranslogFile($F->[$i]); 
  FakeSentBoundary();
  print STDERR "Trl2Treex.pl: adding target $F->[$i]\n";
  if(CheckSRCToken($LastSRC, $TOK->{src})) {
    print STDERR "ReadTranslog: TokenDiff $F->[0], $F->[$i]\n";
    next;
  }
  AppendTargetZone($F->[$i]);
}

AttachUnAlignedNodes(@unaligned_nodes);

$doc->save("$OutFile.treex.gz");

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

  foreach my $id (sort {$a <=> $b} keys %{$T1}) { 
    if(!defined($T2->{$id})) { print STDERR "CheckSRCToken: undefined token ID $id\n"; return 1;}
    if($T1->{$id}{tok} ne $T2->{$id}{tok}) { print STDERR "CheckSRCToken: unequal token $T1->{$id}{tok}\t$T2->{$id}{tok}\n"; return 1;}
  }
  return 0;
}



## SourceText Positions
sub ReadTranslogFile {
  my ($fn) = @_;
  my ($type, $time, $id);

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
      if(/id="([^"]*)"/)    {$id = $1;}
      if(/cur="([0-9][0-9]*)"/) {$TOK->{src}{$id}{cur} = $1;}
      if(/last="([^"]*)"/)  {$TOK->{src}{$id}{last} = $1;}
      if(/tok="([^"]*)"/)   {$TOK->{src}{$id}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$TOK->{src}{$id}{space} = MSunescape($1);}
      if(/out="([^"]*)"/)   {$TOK->{src}{$id}{out} = $1;}
      if(/in="([^"]*)"/)    {$TOK->{src}{$id}{in} = $1;}
    }

    elsif($type == 8 && /<Token/) {
      if(/id="([^"]*)"/)    {$id = $1;}
      if(/cur="([^"]*)"/) {$TOK->{fin}{$id}{cur} = $1;}
      if(/last="([^"]*)"/)  {$TOK->{fin}{$id}{last} = $1;}
      if(/tok="([^"]*)"/)   {$TOK->{fin}{$id}{tok} = MSunescape($1);}
      if(/space="([^"]*)"/) {$TOK->{fin}{$id}{space} = MSunescape($1);}
      if(/out="([^"]*)"/)   {$TOK->{fin}{$id}{out} = $1;}
      if(/in="([^"]*)"/)    {$TOK->{fin}{$id}{in} = $1;}
      if(/id="([^"]*)"/)    {$TOK->{fin}{$id}{id} = $1;}
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

}

sub FakeSentBoundary {

  foreach my $id (keys %{$TOK->{src}}) {
    if($TOK->{src}{$id}{tok} =~ /^[.?!]$/) { $TOK->{src}{$id}{"last"} = "sent";}
#    if($TOK->{src}{$id}{tok} =~ /^[.?!]$/) { print STDERR "last src\n"; }
  }

  my $xx = 0;
  foreach my $id (keys %{$TOK->{fin}}) {
#    if($TOK->{fin}{$id}{tok} =~ /^[.?!]$/ && $xx == 1) { $xx = 0; }
    if($TOK->{fin}{$id}{tok} =~ /^[.?!]$/) {$TOK->{fin}{$id}{"last"} = "sent";}
#    if($TOK->{fin}{$id}{tok} =~ /^[.?!]$/) { print STDERR "last tgt\n";}
  }
}

################################################
#  Create Source Zone
################################################

sub CreateSourceZone {
  my ($fn) = @_;
  my $ord;

  if($TargetLanguage eq '' || $SourceLanguage eq '') {
    print STDERR "$fn Undefined Languages\n";
    exit 1;
  }

  $doc->wild->{annotation}{sourceLanguage} = $SourceLanguage;

  my $zone_src = $bundle->create_zone($SourceLanguage, "source");
  my $root_src = $zone_src->create_atree;

#    $root_src->wild->{SourceLanguage} = $SourceLanguage;
#    $bundle->wild->{SourceLanguage} = $SourceLanguage;

  my $sent = 1;
  my $first = 0;
  
  foreach my $id (sort {$a <=> $b} keys %{$TOK->{src}}) {
      if($first == 1) {
        $bundle = $doc->create_bundle();
        $zone_src = $bundle->create_zone($SourceLanguage, "source");
        $root_src = $zone_src->create_atree;
        $sent ++;
        $first = 0;
        $doc->wild->{annotation}{segmentation} = "source";
      }
      $ord = $id;
      my $node = $root_src->create_child(ord=>$ord);

      $node->set_form($TOK->{src}{$id}{tok});
      $node->set_id("src_$id");
      $node->wild->{linenumber} = $id;
      $node->wild->{sent_number} = $sent;
      if(defined($TOK->{src}{$id}{"last"}) && $TOK->{src}{$id}{"last"} eq "sent") { 
        $node->wild->{boundary} = "sent";
        $first = 1;
      }
      foreach my $attr (keys %{$TOK->{src}{$id}}) { $node->wild->{$attr} = $TOK->{src}{$id}{$attr};}
  }
}

################################################
#  Append Target Zone
################################################

sub AppendTargetZone {
  my ($fn) = @_;
  my $ord;

  if($TargetLanguage eq '' || $SourceLanguage eq '') {
    print STDERR "$fn Undefined Languages\n";
    exit 1;
  }

  my ($study) = $fn =~ /data\/([a-zA-Z0-9]*)\//;
  my $recording = $fn;
  $recording =~ s/^.*\///;
  $recording =~ s/.Event.xml//;
  $recording =~ s/[._]//;

  $bundle = $first_bundle;
  my $zone_tgt = $bundle->create_zone($TargetLanguage, "$study$recording");
  my $root_tgt = $zone_tgt->create_atree;
  $zone_tgt->{wild}{annotation}{filename} = $fn;

#print STDERR "XXXXXX $study$fn\n";

#  foreach my $t (keys %{$FIX}) {
#
#    if($FIX->{$t}{win} != 1 && $FIX->{$t}{win} != 2) {next;}
#
#    foreach my $attr (keys %{$FIX->{$t}}) { 
#      if($attr eq 'tid') { $root_tgt->wild->{FIX}{$t}{tid} = $fn."_".$FIX->{$t}{tid};}
#      elsif($attr eq 'sid') { $root_tgt->wild->{FIX}{$t}{sid} = "src_$FIX->{$t}{sid}";}
#      else { $root_tgt->wild->{FIX}{$t}{$attr} = $FIX->{$t}{$attr};}
#    }
#  }
#
#  foreach my $t (keys %{$KEY}) {
#    if(!defined($KEY->{$t}{'tid'})) { 
#      print STDERR "$fn\t KEY id undefined: $t\n";
#      d($KEY->{$t});
#      next;
#    }
#
#    foreach my $attr (keys %{$KEY->{$t}}) { 
#      if($attr eq 'tid') { $root_tgt->wild->{KEY}{$t}{tid} = $fn."_".$KEY->{$t}{tid};}
#      elsif($attr eq 'sid') { $root_tgt->wild->{KEY}{$t}{sid} = "src_$KEY->{$t}{sid}";}
#      else { $root_tgt->wild->{KEY}{$t}{$attr} = $KEY->{$t}{$attr};}
#    }
#  }

  my $sent = 1;
  foreach my $id (sort {$a <=> $b} keys %{$TOK->{fin}}) {
    $ord = $id;
    my $node = $root_tgt->create_child(ord=>$ord);

    my $tid = $TOK->{fin}{$id}{id};
    if(defined($ALN->{tid}{$tid})) {
      foreach my $sid (keys %{$ALN->{tid}{$tid}{sid}}) {
##printf STDERR "TGT: $TOK->{fin}{$id}{id} $id a:$sid node:%s\n", $doc->get_node_by_id("src_$sid");
        $node->add_aligned_node($doc->get_node_by_id("src_$sid"), 'alignment');
      }
      my @anodes = $node->get_aligned_nodes_of_type("alignment");

      foreach my $anode (@anodes) {

### aligned nodes must be in same bundle printf STDERR "AAAA: %s\t%s\n", $anode->get_bundle()->id(), $bundle->id();
        if($anode->get_bundle()->id() ne $bundle->id()) {
          $bundle = $anode->get_bundle();
          $zone_tgt = $anode->get_bundle()->get_or_create_zone($TargetLanguage, "$study$recording");
          $zone_tgt->{wild}{annotation}{filename} = $fn;
          if($zone_tgt->has_atree) {
            printf STDERR "WARNING: used tree $study$fn\tbundle:%s\ttoken:%s\tform:%s\n", 
                   $bundle->id(), $tid,  $TOK->{fin}{$id}{tok};
            $root_tgt = $zone_tgt->get_atree();
          }
          else {$root_tgt = $zone_tgt->create_atree;}
          $node->set_parent($root_tgt);
          last;
        }
      }
    }
    else { push(@unaligned_nodes, $node);}
      

#printf STDERR "TGT: $TOK->{fin}{$id}{id} $id a:$sid node:%s\n", $doc->get_node_by_id("src_$sid");

    if(defined($TOK->{fin}{$id}{last}) && $TOK->{fin}{$id}{last} eq "sent") { $sent ++;}

    $node->set_form($TOK->{fin}{$id}{tok});
    $node->set_id($fn."_".$TOK->{fin}{$id}{id});
    $node->wild->{linenumber} = $TOK->{fin}{$id}{id};
    $node->wild->{sent_number} = $sent;
    if(defined($TOK->{fin}{$id}{"last"})) { $node->wild->{boundary} = $TOK->{fin}{$id}{"last"}}

    foreach my $attr (keys %{$TOK->{fin}{$id}}) { $node->wild->{$attr} = $TOK->{fin}{$id}{$attr};}

#print STDERR "TGT tgt: $TOK->{fin}{$id}{id} $TOK->{fin}{$id}{tok} $tid\n";
#d($ALN->{tid}{$tid});

  }
  return @unaligned_nodes;
}

sub AttachUnAlignedNodes {
  my (@unaligned_nodes) = @_;

  foreach my $node (@unaligned_nodes) {
    my $left = $node->get_left_neighbor();
    my $right = $node->get_right_neighbor();

#printf STDERR "Node0 b:%s n:%s n:%s\tf:%s\n", $node->get_bundle()->id(), $node->{wild}{id},  $node->selector, $node->form;

    if (!defined($left)) { next;}   ## first node in tree
    if (defined($right) && $right->get_aligned_nodes_of_type("alignment")) {next;}

    if(defined($left->wild->{boundary}) && $left->wild->{boundary} eq "sent") {
      my $next_zone = get_next_zone($node->get_zone());
      if(!defined($next_zone)){
        printf STDERR "Undefined Next Zone %s %s\n"; $node->get_bundle()->id(), $node->form;
        next;
      }
      my $first = $next_zone->get_atree()->get_descendants({first_only=>1});

      $node->set_parent($first->get_root);
      $node->shift_before_node($first);
      print STDERR "Moving node to next bundle\n"; d($node->wild)
    }
  }
}

sub get_next_zone {
  my ($zone) = @_;

  my @bundles = $zone->get_document()->get_bundles();
  my $id = $zone->get_bundle()->id();
  my $einsmehr = 0;
  foreach my $bundle (@bundles) {
      if($einsmehr == 1) { return $bundle->get_zone($zone->language, $zone->selector);}
      if($bundle->id() eq $id) {$einsmehr = 1;}
  }
  return undef;
}

