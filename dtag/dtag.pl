#!/usr/bin/perl -w
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

#!/usr/bin/perl -w

# Version
my $RELEASE = '1.0.47 (2010-06-08 17:29:56)';

use strict;
use File::Basename;
use Encode;
use Cwd;

#binmode(STDOUT, ":encoding(UTF-8)");

# Find DTAGHOME
my $DTAGHOME = $ENV{'DTAGHOME'} || "";
if (! ($DTAGHOME && -r $DTAGHOME)) {
	# Find directory path to this script
	my $script = $0;

	# Resolve symbolic links
	while (-l $script) {
		my $linkfile = readlink($script);
		if ($linkfile !~ /^\//) {
			$linkfile = dirname($script) . "/" . $linkfile;
		}
		$script = $linkfile;
	}

	# Find absolute path and save in DTAGHOME
	$DTAGHOME = Cwd::abs_path(dirname($script)) if (-r $script) || "";
}

# Add $DTAGHOME to @INC, and load modules
push @INC, $DTAGHOME;
require DTAG::Graph;
require DTAG::Interpreter;
require DTAG::Lexicon;
require DTAG::LexInput;
require DTAG::Parse;
require DTAG::Learner;
require DTAG::Alignment;
require DTAG::ALexicon;

# Create new interpreter object and setup signal handling
my $inter = DTAG::Interpreter->new();
sub catch_signal {
	my $signame = shift;
	$inter->signal_handler($signame);
}
$SIG{INT} = \&catch_signal;

# Process options -q, -i, and -u
my $quiet = 0;
my $init = 1;
$inter->unsafe(1);
foreach my $arg (@ARGV) {
	$quiet = 1 if ($arg eq "-q");
	$init = 0 if ($arg eq "-i");
	$inter->unsafe(0) if ($arg eq "-s");
}

# Print copyright information
$inter->quiet($quiet);
if (! $quiet) {
	print "Welcome to DTAG dependency tagger v. $RELEASE\n";
	print "Copyright (c) 2002-2010 Matthias Buch-Kromann\n";
	print "Using DTAG directory $DTAGHOME\n";
}

# Process rc-file
$inter->quiet(1);
if ($init) {
	foreach my $rcfile (($DTAGHOME || "XXX") . "/.dtagrc", 
			($ENV{'HOME'} || "XXX") . "/.dtagrc", ".dtagrc") {
		if (-r $rcfile) {
			print "Using rcfile $rcfile\n" if (! $quiet);
			$inter->do("script $rcfile");
		}
	}
}
$inter->quiet($quiet);
$inter->var("user", "none");

# Process command line arguments
while (@ARGV) {
	my $arg = shift(@ARGV);
	if ($arg eq "-s") {
		$inter->do("script " . shift(@ARGV));
	} elsif ($arg eq "-e") {
		$inter->do(shift(@ARGV), 1);
	} elsif ($arg eq "-E") {
		$inter->do(shift(@ARGV));
	}
}

# Interpret input until "exit"
$inter->loop();

