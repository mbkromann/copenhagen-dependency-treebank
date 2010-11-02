package DTAG::Space;
use strict;
#use Math::CDF;

# Lexicon containing hierarchies used for subdivision
my $lexicon = undef;

# The prior probability distribution over the space, defined as a
# function &$prior($box). 
my $prior = undef;

# Total number of observations in entire space
my $total = 0;

# Number of smoothing observations (the number of ficticious observations
# distributed uniformly across the entire space according to the prior
# distribution)
my $smooth = 1;

# The minimum number of data in a space 
my $mincount = 10;

# The minimum number of moved nodes in a partitioning
my $minmoved = 1;

# The confidence interval used in the statistical test of the
# zero-hypothesis that the data follow the prior distribution
my $confidence = 0.95;

# The G-function used when testing the zero-hypothesis that the data
# follow the prior distribution (the function g(d) = d^2/2 corresponds
# to Pearson's chi-square test)
my $gfunction = 
	sub {
		my $delta = shift; 
		return $delta * $delta / 2
	};


# PostScript header and trailer for printing density diagrams
#my $src = $ENV{DTAGHOME} || "/opt/dtag/";
#my $header = Graph::readfile("$src/boxes.header");
#my $trailer = Graph::readfile("$src/boxes.trailer");

