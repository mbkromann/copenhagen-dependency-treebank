#!/usr/bin/perl -w

use strict;

# Cleanup conll-files to remove line-numbering from features-column

my $sessionID = $ARGV[0];
my $language = $ARGV[1];


$sessionID = 0;
$language = "it";

open (FILES, "$sessionID-$language.trainingFiles.lst");
while (my $line = <FILES>) {

    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;
    my $lFilename = "$sessionID-$language.$1.conll";
    
    open(OLD, "$lFilename");
    open(NEW, ">$lFilename.cleaned");

    while (my $cLine = <OLD>) {

	chomp $cLine;

	if ($cLine eq "") {
	    print NEW "$cLine\n";
	} else {
	    my @tokens = split("\t", $cLine);
	    my $featToken = $tokens[5];
	    $featToken =~ s/line=\d+/_/g;
	    $featToken =~ s/\|_//g;
	    $tokens[5] = $featToken;
	    
	    my $newLine = join("\t", @tokens);
	    print NEW "$newLine\n";
	}
    }
    close(OLD);
    close(NEW);

    
}
close (FILES);

open (FILES, "$sessionID-$language.toParseFiles.lst");
while (my $line = <FILES>) {

    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;
    my $lFilename = "$sessionID-$language.$1.conll.segmented";
    
    
    open(OLD, "$lFilename");
    open(NEW, ">$lFilename.cleaned");

    while (my $cLine = <OLD>) {

	chomp $cLine;

	if ($cLine eq "") {
	    print NEW "$cLine\n";
	} else {
	    my @tokens = split("\t", $cLine);
	    my $featToken = $tokens[5];
	    $featToken =~ s/line=\d+/_/g;
	    $featToken =~ s/\|_//g;
	    $tokens[5] = $featToken;
	    
	    my $newLine = join("\t", @tokens);
	    print NEW "$newLine\n";
	}
    }
    close(OLD);
    close(NEW);

    
}
close (FILES);
