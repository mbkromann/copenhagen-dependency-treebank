#!/usr/bin/perl

# LaTeX headings
my @headings = ("\\chapter", "\\section", "\\subsection", "\\subsubsection");

# Read arguments
my $dispfile = shift(@ARGV);
my $outprefix = shift(@ARGV);
if (! ($dispfile && $outprefix)) {
	print "Usage: disp2script <dispfile> <outfileprefix>\n";
	print "Create .tex and .dtag scripts from disposition file\n";
	exit(1);
}

# Open files
open(DISP, "<:encoding(UTF-8)", $dispfile)
	|| die "Could not open $dispfile for reading: $!";
open(TEX, ">:encoding(UTF-8)", "$outprefix.tex") 
	|| die "Could not open $outprefix.tex for writing: $!";
open(DTAG, ">:encoding(UTF-8)", "$outprefix.dtag")
	|| die "Could not open $outprefix.dtag for writing: $!";
open(OTEX, ">:encoding(UTF-8)", "$outprefix-overviews.tex");

# Process disposition
my $overviews = "";
while (my $line = <DISP>) {
	chomp($line);

	if ($line !~ /^\s*$/) {
		# Split line into indented type description and heading
		my ($itype, $heading) = split(/\s*\:\s*/, $line);

		# Split indented type description into indent and type 
		$itype =~ /^([> ]*)([^ >].*)$/;
		my ($istring, $type) = ($1, $2);
		$istring =~ s/\s+//g;
		my $indent = length($istring);

		# Find first type
		$type =~ /^([^-]*).*$/;
		my $type1 = $1 ? ": $1" : "";

		# Create TEX file name
		my $file = $outprefix . "-" . $type . ".tex";
		my $overviewfile = $outprefix . "-" . $type . "-overview.tex";

		# TeX output
		print TEX 
			$headings[$indent] . "{" . $heading . $type1 . "}\n\n"
			. "\t\\input{" . $file . "}\n\n";
		print OTEX
			"\\overviewfile{$overviewfile}\n\n";

		# DTAG output
		print DTAG "relset2latex -file=" . $file . " " . $type . "\n";

		# Debugging output
		print "indent=$indent type=$type heading=$heading\n";
	}
}

close(OTEX);
close(TEX);
close(DTAG);
