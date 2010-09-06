#!/usr/bin/perl -w

use strict;
use Cwd;

# Necesary for cron-stuff
system("export PERL5LIB=/srv/tools/SVMTool-1.3.1/lib:\$PERL5LIB");
system(". /srv/sge6-2/sge_login/common/settings.sh");


my $language = $ARGV[0];

# If 0 all commands are only printed - not executed. Used for debugging.
my $execute = 1;

# Does not work with cron because sge-settings are not applied properly
my $useSGE = 0;

my $pruneAccuracy = 0.8;

# Get sessionID and update sessionID-file
open(SID, "lastSessionID");
my $sessionID = <SID>;
chomp $sessionID;
close(SID);


$sessionID++;
open(SID, ">lastSessionID");
print SID "$sessionID\n";
close(SID);


my $ID = "$sessionID-$language";
my $cmd = "";

    my $dir = getcwd;

# Update
$cmd = "cd ../$language";
print "$cmd\n";
if ($execute) {
    chdir("../$language");
}

$cmd = "svn update";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

$cmd = "cd $dir";
print "$cmd\n";
if ($execute) {
    chdir($dir);
}


# Find files to use for training and files to be parser
$cmd = "perl findFiles.pl $sessionID $language > $ID.findFiles.out 2> $ID.findFiles.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# Convert files to CoNNL-format
$cmd = "perl convertToConll.pl $sessionID $language > $ID.convertToConnl.out 2> $ID.convertToConnl.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Sentence-segmentation of files to parse

# First create list of conll files to segment:
$cmd = "perl createSegmenterFileLists.pl $sessionID $language 2> $ID.createSegmenterFileLists.err > $ID.createSegmenterFileLists.out";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Then create .txt files for segmenter
$cmd = "perl ../automaticSentenceSegmentation/createtoSegmentFiles.pl $ID.toParseFiles.lst.abs 2> $ID.createtoSegmentFiles.err > $ID.createtoSegmentFiles.out";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Segment txt-files
$cmd = "perl ../automaticSentenceSegmentation/segmentFiles.pl $ID.toParseFiles.lst.abs it 2> $ID.segmentFiles.err > $ID.segmentFiles.out";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# Update conll-files with sentence-segmentation
$cmd = "perl segmentConllFiles.pl $sessionID $language > $ID.segmentConllFiles.out 2> $ID.segmentConllFiles.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# Cleanup CoNNL-files (remove line-numbers from feature-column)
$cmd = "perl cleanupConll.pl $sessionID $language > $ID.cleanupConll.out 2> $ID.cleanupConll.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Join CoNNL files for training and parsing
$cmd = "perl createParserFiles.pl $sessionID $language > $ID.createParserFiles.out 2> $ID.createParserFiles.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Create scripts to train parser and parse sentences
$cmd = "perl createParserScripts.pl $sessionID $language > $ID.createParserScripts.out 2> $ID.createParserScripts.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Run training
$cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.train.sh";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Run parsing
$cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.parse.sh";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# Parsing of training files
$cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.parse-trainingdata.sh";
print "$cmd\n";
if ($execute) {
    system($cmd);
}




# Create statistics
$cmd = "perl createStats.pl $ID.train.conll $ID.training.out.conll > $ID.stats";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# Prune output from parser
$cmd = "perl prune.pl $ID.stats $ID.out.conll $pruneAccuracy > $ID.out.conll.pruned";
print "$cmd\n";
if ($execute) {
    system($cmd);
}



# Split parsed file into original texts
$cmd = "perl splitParsedFiles.pl $sessionID $language > $ID.splitParsedFiles.out 2> $ID.splitParsedFiles.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# Put result of parsing into conll-files with line numbers
$cmd = "perl mergeAll.pl $sessionID $language > $ID.mergeAll.out 2> $ID.mergeAll.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}



# Merge conll-files with tag-files
$cmd = "perl mergeAllTag.pl $sessionID $language > $ID.mergeAllTag.out 2> $ID.mergeAllTag.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Update out-feature in tag-files
$cmd = "perl updateAllTag.pl $sessionID $language > $ID.updateAllTag.out 2> $ID.updateAllTag.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

# Copy tag-files to original folder
$cmd = "perl copyTagFiles.pl $sessionID $language > $ID.copyTagFiles.out 2> $ID.copyTagFiles.err";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# Update svn

$cmd = "cd ../$language";
print "$cmd\n";
if ($execute) {
    chdir("../$language");
}

$cmd = "svn update";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

$cmd = "svn add *auto*.tag";
print "$cmd\n";
if ($execute) {
    system($cmd);
}

$cmd = "svn commit -m 'Automatic annotations, $ID'";
print "$cmd\n";
if ($execute) {
    system($cmd);
}


# 
