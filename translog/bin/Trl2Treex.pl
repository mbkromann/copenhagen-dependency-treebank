#!/usr/bin/perl 

use strict;
use warnings;
use Getopt::Std;
use Treex::Core;

use Data::Dumper; $Data::Dumper::Indent = 1;
sub d { print STDERR Data::Dumper->Dump([ @_ ]); }

my $usage =
  "Create Treex file from Translog-II Event files: \n".
  "  -T in:  Translog *.Event.xml file <fn1,fn2,...,fn_n>\n".
  "  -O out: Write output <filename>.treex.gz\n".
  "Options:\n".
  "  -v verbose mode [0 ... ]\n".
  "  -h this help \n".
  "\n";

use vars qw ($opt_O $opt_T $opt_v $opt_h);
getopts ('T:O:v:h');


die $usage if defined($opt_h);
die $usage if not defined($opt_T);
die $usage if not defined($opt_O);

my $map = { map { $_ => 1 } split( //o, "\\<> \t\n\r\f\"" ) };

my $Verbose = 0;

my $AlignmentHeader = '';
my $SourceTokenHeader = '';
my $FinalTokenheader = '';

my $SourceLanguage = '';
my $TargetLanguage = '';

my $TOK;
my $ALN;

my $doc = Treex::Core::Document->new;
my $bundle = $doc->create_bundle;
my $first_bundle = $bundle;
my @unaligned_nodes; 

my $F = [split(/[ \,\n\t]+/, $opt_T)];

ReadTranslogFile($F->[0]); 
#FakeSentBoundary();
CreateSourceZone($F->[0]);
AppendTargetZone($F->[0]);
#print STDERR "Trl2Treex.pl: creating source $F->[0]\n";

my $LastSRC = $TOK->{src};

for (my $i= 1; $i<= $#{$F}; $i++) {
  $TOK = $ALN = undef;

  ReadTranslogFile($F->[$i]); 
#  FakeSentBoundary();
  print STDERR "Trl2Treex.pl: adding target $F->[$i]\n";
  if(CheckSRCToken($LastSRC, $TOK->{src})) {
    print STDERR "ReadTranslog: TokenDiff $F->[0], $F->[$i]\n";
    next;
  }
  AppendTargetZone($F->[$i]);
}


AttachUnAlignedNodes(@unaligned_nodes);
$doc->save("$opt_O.treex.gz");

exit;


##########################################################
# Read Translog Logfile
##########################################################
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

## Check ids and token identity in the two src,tgt hashes
sub CheckSRCToken {
  my ($T1, $T2) = @_;

  foreach my $id (sort {$a <=> $b} keys %{$T1}) { 
    if(!defined($T2->{$id})) { print STDERR "CheckSRCToken: undefined token ID $id\n"; return 1;}
    if($T1->{$id}{tok} ne $T2->{$id}{tok}) { print STDERR "CheckSRCToken: unequal token $T1->{$id}{tok}\t$T2->{$id}{tok}\n"; return 1;}
  }
  return 0;
}


sub TokenAttributes {
  my ($lng, $id, $attribute, $value) = @_;

  $attribute =~ s/^\s+//;
  $attribute =~ s/\s+$//;
  $value =~ s/^\s+//;
  $value =~ s/\s+$//;
  $TOK->{$lng}{$id}{$attribute} = MSunescape($value);
  return $attribute;
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
    elsif(/<Alignment/)   {$type =6; 
      $AlignmentHeader = $_; 
      $AlignmentHeader =~ s/<Alignment//; 
      $AlignmentHeader =~ s/source="[^"]*"//; 
      $AlignmentHeader =~ s/target="[^"]*"//; 
      $AlignmentHeader =~ s/>//;
    }
    elsif(/<SourceToken/) {
        $type =7; 
        $SourceTokenHeader = $_; 
        $SourceTokenHeader =~ s/<SourceToken//;  
        $SourceTokenHeader =~ s/>//;
        if(/language="([^"]*)"/) {$SourceLanguage =$1;}
    }
    elsif(/<FinalToken/)  {
        $type =8; 
        $FinalTokenheader = $_; 
        $FinalTokenheader =~ s/<FinalToken//;  
        $FinalTokenheader =~ s/>//;
        if(/language="([^"]*)"/) {$TargetLanguage =$1;}
    }
	
    elsif($type == 6 && /<Align /) {
#print STDERR "ALIGN: $_";
      my ($si, $ti, $ss, $ts);
      if(/sid="([^"]*)"/)       {$si =$1;}
      if(/tid="([^"]*)"/)       {$ti =$1;}
      $ALN->{'tid'}{$ti}{'sid'}{$si} = $ss;
    }
    elsif($type == 7 && /<Token/) {
      s/<Token//;
      s/\/>//;
      if(/id="([^"]*)"/)    {$id = $1;}
      s/([-_a-zA-Z0-9]+)\s*=\s*"([^"]*)/TokenAttributes("src",$id,$1,$2)/ego;
    }

    elsif($type == 8 && /<Token/) {
      s/<Token//;
      s/\/>//;
      if(/id="([^"]*)"/)    {$id = $1;}
      s/([-_a-zA-Z0-9]+)\s*=\s*"([^"]*)/TokenAttributes("fin",$id,$1,$2)/ego;
    }

    if(/<\/Alignment>/) {$type =0; }
    if(/<\/SourceToken>/){$type =0; }
    if(/<\/FinalToken>/) {$type =0; }
    if(/<\/Fixations>/) {$type =0; }
  }
  close(FILE);
}

sub FakeSentBoundary {

  foreach my $id (keys %{$TOK->{src}}) {
    if($TOK->{src}{$id}{tok} =~ /^[.?!]$/) { $TOK->{src}{$id}{"boundary"} = "sentence";}
#    if($TOK->{src}{$id}{tok} =~ /^[.?!]$/) { print STDERR "boundary src\n"; }
  }

  my $xx = 0;
  foreach my $id (keys %{$TOK->{fin}}) {
#    if($TOK->{fin}{$id}{tok} =~ /^[.?!]$/ && $xx == 1) { $xx = 0; }
    if($TOK->{fin}{$id}{tok} =~ /^[.?!]$/) {$TOK->{fin}{$id}{"boundary"} = "sentence";}
#    if($TOK->{fin}{$id}{tok} =~ /^[.?!]$/) { print STDERR "boundary tgt\n";}
  }
}

################################################
#  Create Source Zone
################################################

sub HeaderAttributes {
  my ($zone, $attribute, $value) = @_;

  $zone =~ s/^\s+//;
  $zone =~ s/\s+$//;
  $attribute =~ s/^\s+//;
  $attribute =~ s/\s+$//;
  $value =~ s/^\s+//;
  $value =~ s/\s+$//;
  $doc->wild->{annotation}{$zone}{$attribute}  = $value;
#  $H->{$zone}{$attribute}  = $value;
  return $attribute;
}

sub CreateSourceZone {
  my ($fn) = @_;

  if($TargetLanguage eq '' || $SourceLanguage eq '') {
    print STDERR "$fn Undefined Languages\n";
    exit 1;
  }

  $SourceTokenHeader =~ s/ ([^=]*)="([^"]*)"/HeaderAttributes("source", $1, $2)/ego;

  my $zone_src = $bundle->create_zone($SourceLanguage, "source");
  my $root_src = $zone_src->create_atree;

  my $sent = 1;
  my $first = 0;
  
  foreach my $id (sort {$a <=> $b} keys %{$TOK->{src}}) {
#print STDERR "xxx: $id\n";
#d($TOK->{src}{$id});
      if($first == 1) {
        $bundle = $doc->create_bundle();
        $zone_src = $bundle->create_zone($SourceLanguage, "source");
        $root_src = $zone_src->create_atree;
        $sent ++;
        $first = 0;
      }
      my $node = $root_src->create_child(ord=>$id);

      if(defined($TOK->{src}{$id}{tok})) {$node->set_form($TOK->{src}{$id}{tok});}
      if(defined($TOK->{src}{$id}{pos})) {$node->set_tag($TOK->{src}{$id}{pos});}
      if(defined($TOK->{src}{$id}{lemma})) {$node->set_lemma($TOK->{src}{$id}{lemma});}
      $node->set_id("src_$id");
      $node->wild->{linenumber} = $id;
      $node->wild->{sent_number} = $sent;
      if(defined($TOK->{src}{$id}{"boundary"}) && $TOK->{src}{$id}{"boundary"} eq "sentence") { 
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

  if($TargetLanguage eq '' || $SourceLanguage eq '') {
    print STDERR "$fn Undefined Languages\n";
    exit 1;
  }

  my ($study) = $fn =~ /data\/([a-zA-Z0-9]*)\//;
  $fn =~ s/.Event.xml//;
  my $recording = $fn;

  $recording =~ s/^.*\///;
  $recording =~ s/[._]//;

  $bundle = $first_bundle;
  my $selector = "$study$recording";
  my $zone_tgt = $bundle->create_zone($TargetLanguage, "$selector");
  my $root_tgt = $zone_tgt->create_atree;

#print STDERR "FinalTokenheader: $FinalTokenheader\n";
  $FinalTokenheader =~ s/ ([^=]*)="([^"]*)"/HeaderAttributes($selector, $1, $2)/ego;
  $AlignmentHeader =~ s/ ([^=]*)="([^"]*)"/HeaderAttributes($selector, $1, $2)/ego;
  $doc->wild->{annotation}{"$selector"}{fileName}  = $fn;

  my $sent = 1;
  foreach my $id (sort {$a <=> $b} keys %{$TOK->{fin}}) {
    my $node = $root_tgt->create_child(ord=>$id);

    if(defined($ALN->{tid}{$id})) {
      foreach my $sid (keys %{$ALN->{tid}{$id}{sid}}) {
##printf STDERR "TGT: $TOK->{fin}{$id}{id} $id a:$sid node:%s\n", $doc->get_node_by_id("src_$sid");
        $node->add_aligned_node($doc->get_node_by_id("src_$sid"), 'alignment');
#        $node->wild->{alignment}{$sid}++;
      }
      my @anodes = $node->get_aligned_nodes_of_type("alignment");

      foreach my $anode (@anodes) {

### aligned nodes must be in same bundle printf STDERR "AAAA: %s\t%s\n", $anode->get_bundle()->id(), $bundle->id();
        if($anode->get_bundle()->id() ne $bundle->id()) {
          $bundle = $anode->get_bundle();
          $zone_tgt = $anode->get_bundle()->get_or_create_zone($TargetLanguage, $selector);
          if($zone_tgt->has_atree) {
            printf STDERR "WARNING: word crossing sentence alignment ignored $selector\tbundle:%s\ttoken:%s\tform:%s\n", 
                   $bundle->id(), $id,  $TOK->{fin}{$id}{tok};
#            $root_tgt = $zone_tgt->get_atree();
#            $node->wild->{alignmentError} ++;
          }
          else {$root_tgt = $zone_tgt->create_atree;}
          $node->set_parent($root_tgt);
          last;
        }
      }
    }
    else { push(@unaligned_nodes, $node);}
      
#printf STDERR "TGT: $TOK->{fin}{$id}{id} $id a:$id node:%s\n", $doc->get_node_by_id("src_$id");

    if(defined($TOK->{fin}{$id}{boundary}) && $TOK->{fin}{$id}{boundary} eq "sentence") { $sent ++;}

    if(defined($TOK->{fin}{$id}{tok})) {$node->set_form($TOK->{fin}{$id}{tok});}
    if(defined($TOK->{fin}{$id}{pos})) {$node->set_tag($TOK->{fin}{$id}{pos});}
    if(defined($TOK->{fin}{$id}{lemma})) {$node->set_lemma($TOK->{fin}{$id}{lemma});}
    $node->set_id($selector."_".$id);
    $node->wild->{linenumber} = $id;
    $node->wild->{sent_number} = $sent;
#    if(defined($TOK->{fin}{$id}{"boundary"})) { $node->wild->{boundary} = $TOK->{fin}{$id}{"boundary"}}

    foreach my $attr (keys %{$TOK->{fin}{$id}}) { $node->wild->{$attr} = $TOK->{fin}{$id}{$attr};}

#print STDERR "TGT tgt: $TOK->{fin}{$id}{id} $TOK->{fin}{$id}{tok} $id\n";
#d($ALN->{tid}{$id});

  }
  return @unaligned_nodes;
}

sub AttachUnAlignedNodes {
  my (@unaligned_nodes) = @_;

LonelyNode:
  foreach my $node (@unaligned_nodes) {
    my $left = $node->get_left_neighbor();

#printf STDERR "Node0 b:%s n:%s n:%s\tf:%s\n", $node->get_bundle()->id(), $node->{wild}{id},  $node->selector, $node->form;
    if (!defined($left)) { next;}   ## first node in tree

    my $right = $node->get_right_neighbor();
## skip it a node to the right is in the same zone
    while(defined($right)) {
      if($right->get_aligned_nodes_of_type("alignment")) {next LonelyNode;}
      $right = $right->get_right_neighbor();
    }

#printf STDERR "Node1 %s:'%s'\n", $node->id, $node->form;
    if(defined($left->wild->{boundary}) && $left->wild->{boundary} eq "sentence") {
      my $next_zone = get_next_zone($node->get_zone());
      if(!defined($next_zone)){
        printf STDERR "Undefined Next Zone %s %s\n", $node->get_bundle()->id(), $node->form;
        next;
      }

      my $first = $next_zone->get_atree()->get_descendants({first_only=>1});
      $node->set_parent($first->get_root);
      while(defined($first)) {
#printf STDERR "Node1 compare %s/%s and %s/%s\n", $node->wild->{id}, $node->ord, $first->wild->{id}, $first->ord;
        if($first->wild->{id} > $node->wild->{id}) {last;}
        $first = $first->get_right_neighbor();
      }
      $node->shift_before_node($first);
      printf STDERR "Moving node %s:'%s' to next bundle before node %s:'%s'\n",
              $node->wild->{id}, $node->form,  $first->wild->{id},  $first->form, ; 
    }
  }
}

sub get_next_zone {
  my ($zone) = @_;

  my @bundles = $zone->get_document()->get_bundles();
  my $einsmehr = 0;
  my $id = $zone->get_bundle()->id();
  foreach my $bundle (@bundles) {
      if($einsmehr == 1) { return $bundle->get_zone($zone->language, $zone->selector);}
      if($bundle->id() eq $id) {$einsmehr = 1;}
  }
  return undef;
}

