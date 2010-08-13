#!/usr/bin/perl -w

use strict;

my $language = $ARGV[0];

my $useSGE = 1;

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

# Find files to use for training and files to be parser
print "findFiles.pl\n";
system("perl findFiles.pl $sessionID $language > $ID.findFiles.out 2> $ID.findFiles.err");


# Convert files to CoNNL-format
print "convertToConll.pl\n";
system("perl convertToConll.pl $sessionID $language > $ID.convertToConnl.out 2> $ID.convertToConnl.err");

# Sentence-segmentation of files to parse

# First create list of conll files to segment:
print "createSegmenterFileLists.pl\n";
system("perl createSegmenterFileLists.pl $sessionID $language 2> $ID.createSegmenterFileLists.err > $ID.createSegmenterFileLists.out");

# Then create .txt files for segmenter
print "../automaticSentenceSegmentation/createtoSegmentFiles.pl\n";
system("perl ../automaticSentenceSegmentation/createtoSegmentFiles.pl $ID.toParseFiles.lst.abs 2> $ID.createtoSegmentFiles.err > $ID.createtoSegmentFiles.out");

# Segment txt-files
print "../automaticSentenceSegmentation/segmentFiles.pl\n";
system("perl ../automaticSentenceSegmentation/segmentFiles.pl $ID.toParseFiles.lst.abs it 2> $ID.segmentFiles.err > $ID.segmentFiles.out");


# Update conll-files with sentence-segmentation
print "segmentConllFiles.pl\n";
system("perl segmentConllFiles.pl $sessionID $language > $ID.segmentConllFiles.out 2> $ID.segmentConllFiles.err");


# Cleanup CoNNL-files (remove line-numbers from feature-column)
print "cleanupConll.pl\n";
system("perl cleanupConll.pl $sessionID $language > $ID.cleanupConll.out 2> $ID.cleanupConll.err");

# Join CoNNL files for training and parsing
print "createParserFiles.pl\n";
system("perl createParserFiles.pl $sessionID $language > $ID.createParserFiles.out 2> $ID.createParserFiles.err");

# Create scripts to train parser and parse sentences
print " createParserScripts.pl\n";
system("perl createParserScripts.pl $sessionID $language > $ID.createParserScripts.out 2> $ID.createParserScripts.err");

# Run training
my $cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.train.sh";
print "$cmd\n";
system($cmd);

# Run parsing

$cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.parse.sh";
print "$cmd\n";
system($cmd);

# Parsing of training files
$cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.parse-trainingdata.sh";
print "$cmd\n";
system($cmd);

# Create statistics
print "createStats.pl\n";
system("perl createStats.pl $ID.train.conll $ID.training.out.conll > $ID.stats");

# Prune output from parser
print "prune.pl\n";
system("perl prune.pl $ID.stats $ID.out.conll $pruneAccuracy > $ID.out.conll.pruned");


# Split parsed file into original texts
print "splitParsedFiles.pl\n";
system("perl splitParsedFiles.pl $sessionID $language > $ID.splitParsedFiles.out 2> $ID.splitParsedFiles.err");

# Put result of parsing into conll-files with line numbers
print "mergeAll.pl\n";
system("perl mergeAll.pl $sessionID $language > $ID.mergeAll.out 2> $ID.mergeAll.err");

# Merge conll-files with tag-files
print "mergeAllTag.pl.pl\n";
system("perl mergeAllTag.pl $sessionID $language > $ID.mergeAllTag.out 2> $ID.mergeAllTag.err");

# Update out-feature in tag-files
print "updateAllTag.pl\n";
system("perl updateAllTag.pl $sessionID $language > $ID.updateAllTag.out 2> $ID.updateAllTag.err");

# Copy tag-files to original folder
# print "copyTagFiles.pl.pl\n";
# system("perl copyTagFiles.pl $sessionID $language > $ID.copyTagFiles.out 2> $ID.copyTagFiles.err");


# Update svn

# 
