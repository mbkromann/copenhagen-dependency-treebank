#!/usr/bin/perl -w

use strict;

# Use svn propget to identify training files and files to be parsed.
# Save lists to files


my $sessionID = $ARGV[0];
my $language = $ARGV[1];

# $sessionID = 0;
# $language = "it";

my @allFilesInfo = `svn pg syntax ../$language/*`;

my @trainingFiles = ();
my @toparseFiles = ();

for my $fileInfo (@allFilesInfo) {

    chomp $fileInfo;

    # Isolate filename from svm info
    $fileInfo =~ /(.*) - .*/;
    my $file = $1; 

    if ($fileInfo =~ /tagged\.tag/) {
	unshift(@toparseFiles, $file);
    } else {
	if ($fileInfo =~ /discussed/ || $fileInfo =~ /first/ || $fileInfo =~ /final/) {
	    if (!($file =~ /disc/)) {
		unshift(@trainingFiles, $file);
	    }
	}
    }
}

open (TRFILES, ">$sessionID-$language.trainingFiles.lst");
for my $f (@trainingFiles) {
    print TRFILES "$f\n";
}
close(TRFILES);

open (TPFILES, ">$sessionID-$language.toParseFiles.lst");
for my $f (@toparseFiles) {
    print TPFILES "$f\n";
}
close(TPFILES);



