#!/usr/bin/perl -w

use strict;

my $language = $ARGV[0];

my $useSGE = 1

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
system("perl findFiles.pl $sessionID $language > $ID.findFiles.out 2> $ID.findFiles.err");

# Convert files to CoNNL-format
system("perl convertToConll.pl $sessionID $language > $ID.convertToConnl.out 2> $ID.convertToConnl.err");

# Sentence-segmentation of files to parse

# First create list of conll files to segment:
system("perl cleanupConll.pl $sessionID $language createSegmenterFileLists.pl 2> $ID.createSegmenterFileLists.err > $ID.createSegmenterFileLists.out");

# Then create .txt files for segmenter
system("perl ../automaticSentenceSegmentation/createtoSegmentFiles.pl $ID.toParseFiles.lst.abs 2> $ID.createtoSegmentFiles.err > 2> $ID.createtoSegmentFiles.out");

# Segment txt-files
system("perl ../automaticSentenceSegmentation/segmentFiles.pl $ID.toParseFiles.lst.abs it 2> $ID.segmentFiles.err > 2> $ID.segmentFiles.out");


# Update conll-files with sentence-segmentation
system("perl segmentConllFiles.pl $sessionID $language > $ID.segmentConllFiles.out 2> $ID.segmentConllFiles.err");


# Cleanup CoNNL-files (remove line-numbers from feature-column)
system("perl cleanupConll.pl $sessionID $language > $ID.cleanupConll.out 2> $ID.cleanupConll.err");

# Join CoNNL files for training and parsing
system("perl createParserFiles.pl $sessionID $language > $ID.createParserFiles.out 2> $ID.createParserFiles.err");

# Create scripts to train parser and parse sentences
system("perl createParserScripts.pl $sessionID $language > $ID.createParserScripts.out 2> $ID.createParserScripts.err");

# Run training
my $cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.train.sh";
system($cmd);

# Run parsing
$cmd = "";
if ($useSGE) {
    $cmd = "qsub -cwd -sync y ";
}
$cmd = $cmd."./R$ID.parse.sh";
system($cmd);

# Split trained file into original texts

system("perl splitParsedFiles.pl $sessionID $language > $ID.splitParsedFiles.out 2> $ID.splitParsedFiles.err");

# Put result of parsing into conll-files with line numbers

system("perl mergeAll.pl $sessionID $language > $ID.mergeAll.out 2> $ID.mergeAll.err");

# Merge conll-files with tag-files
system("perl mergeAllTag.pl $sessionID $language > $ID.mergeAllTag.out 2> $ID.mergeAllTag.err");

# Update out-feature in tag-files
system("perl updateAllTag.pl $sessionID $language > $ID.updateAllTag.out 2> $ID.updateAllTag.err");

# Copy tag-files to original folder
system("perl copyTagFiles.pl $sessionID $language > $ID.copyTagFiles.out 2> $ID.copyTagFiles.err");


# Update svn

# 
