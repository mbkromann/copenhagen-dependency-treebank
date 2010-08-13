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




    my $tag = "$sessionID-$language.$1";

    $line =~ s/tagged/auto/;    
    system("cp $tag $line");

    


}
close(FILES);
