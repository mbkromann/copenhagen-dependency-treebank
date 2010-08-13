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


    my $inTag = "$sessionID-$language.$1.intag";
    my $tag = "$sessionID-$language.$1";

   system("perl ./updateTAG.pl $inTag $tag");


}

close(FILES);
