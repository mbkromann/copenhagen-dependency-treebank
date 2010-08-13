#!/usr/bin/perl -w

use strict;

# Split parsed files into equivalents to the original files

my $sessionID = $ARGV[0];
my $language = $ARGV[1];


# $sessionID = 0;
# $language = "it";


open (FILES, "$sessionID-$language.toParseFiles.lst");

while (my $line = <FILES>) {
    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;

    my $conll = "$sessionID-$language.$1.conll.segmented.cleaned.out.lines";
    my $newTag = "$sessionID-$language.$1.intag";

    system("perl ./mergeConllTag.pl $conll $line $newTag");


}

close(FILES);
