#!/usr/bin/perl -w

use strict;

# Cleanup conll-files to remove line-numbering from features-column

my $sessionID = $ARGV[0];
my $language = $ARGV[1];

my $heapSize = "8192m";
my $mstLocation = "/srv/tools/mstparser";
my $mstOrder = 2;
my $mstDecodeType= "non-proj";



$sessionID = 0;
$language = "it";

my $trainFile = "$sessionID-$language.train.conll";

open(TRAINSCRIPT, ">R$sessionID-$language.train.sh");

print TRAINSCRIPT "#!/bin/bash\n\n";

# If script is run with sge this is needed
print TRAINSCRIPT "#\$ -S /bin/bash\n\n";

print TRAINSCRIPT "java -classpath \"$mstLocation:$mstLocation/lib/trove.jar\" -Xmx$heapSize mstparser.DependencyParser train train-file:$trainFile order:$mstOrder decode-type:$mstDecodeType model-name:$sessionID-$language.model 2> $sessionID-$language.train.err > $sessionID-$language.train.out\n";

close(TRAINSCRIPT);


my $parseFile = "$sessionID-$language.parse.conll";

open(TRAINSCRIPT, ">R$sessionID-$language.parse.sh");

print TRAINSCRIPT "#!/bin/bash\n\n";

# If script is run with sge this is needed
print TRAINSCRIPT "#\$ -S /bin/bash\n\n";

print TRAINSCRIPT "java -classpath \"$mstLocation:$mstLocation/lib/trove.jar\" -Xmx$heapSize mstparser.DependencyParser test test-file:$parseFile order:$mstOrder decode-type:$mstDecodeType model-name:$sessionID-$language.model output-file:$sessionID-$language.out.conll 2> $sessionID-$language.parse.err > $sessionID-$language.parse.out\n";

close(TRAINSCRIPT);


system("chmod u+x $sessionID-$language.train.sh");
system("chmod u+x $sessionID-$language.parse.sh");

