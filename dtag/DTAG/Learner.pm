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


## ------------------------------------------------------------
##  auto-inserted from: Learner/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner - DTAG class for learning lexical relations

=head1 DESCRIPTION

DTAG::Learner - learns a probability distribution over a lexical
relation. 

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Learner;
use strict;

require DTAG::Lexicon;



## ------------------------------------------------------------
##  auto-inserted from: Learner/new.pl
## ------------------------------------------------------------

# Create new learner object

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Return new object
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/test.pl
## ------------------------------------------------------------



sub test {
	my $self = shift;

	# Create hierarchy
	my $hierarchy = DTAG::Learner::UnitBox->new(2, 3);

	# Use uniform distribution as prior
	my $prior = sub { 1 };

	# Use following sample sizes
	my $samples = [10, 30, 100, 300, 1000, 3000, 10000, 30000];
	my $repeat = 10;

	# Use following true distributions
	my $distributions = [
		# 0. Uniform
		[[1, [[0,1],[0,1]]]], 				# 1:[0,1]²

		# 1. Centered box depth 1, noiseless
		[	[1,   [[1/3,2/3],[1/3,2/3]]],	# 1:[1/3,2/3]²
			[0, [[0,1],[0,1]]]],			# 0:[0,1]²

		# 2. Centered box depth 1, 10% noise
		[	[0.9, [[1/3,2/3],[1/3,2/3]]],		# 1:[1/3,2/3]²
			[0.1, [[0,1],[0,1]]]],		# 0:[0,1]²

		# 3. Centered box depth 2, no noise
		[	[1, [[4/9,5/9],[4/9,5/9]]],		# 1:[4/9,5/9]²
			[0, [[0,1],[0,1]]]],			# 0:[0,1]²

		# 4. Centered box depth 2, 10% noise
		[	[0.9,   [[4/9,5/9],[4/9,5/9]]],	# 1:[4/9,5/9]²
			[0.1, [[0,1],[0,1]]]],			# 0:[0,1]²

		# 5. Centered box depth 3, no noise
		[	[1, [[13/27,14/27],[13/27,14/27]]],# 1:[13/27,14/27]²
			[0, [[0,1],[0,1]]]],			# 0:[0,1]²

		# 6. Centered box depth 3, 10% noise
		[	[0.9,   [[13/27,14/27],[13/27,14/27]]],# 1:[13/27,14/27]²
			[0.1, [[0,1],[0,1]]]],			# 0:[0,1]²

		# 7. Centered non-hierarchical box, depth 1, no noise
		[	[1, [[2/5,3/5],[2/5,3/5]]],		# 1:[2/5,3/5]²
			[0, [[0,1],[0,1]]]],			# 0:[0,1]²

		# 8. Centered non-hierarchical box, depth 1, 10% noise
		[	[0.9, [[2/5,3/5],[2/5,3/5]]],		# 1:[2/5,3/5]²
			[0.1, [[0,1],[0,1]]]],		# 0:[0,1]²

		# 9. Centered non-hierarchical box, depth 2, no noise
		[	[1, [[12/25,13/25],[12/25,13/25]]],	# 1:[12/25,13/25]²
			[0, [[0,1],[0,1]]]],			# 0:[0,1]²

		# 10. Centered non-hierarchical box, depth 2, 10% noise
		[	[0.9, [[12/25,13/25],[12/25,13/25]]],	# 1:[12/25,13/25]²
			[0.1, [[0,1],[0,1]]]],		# 0:[0,1]²

		# 11. Equi-diagonal, no noise
		[	[1/3,   [[0/3,1/3],[0/3,1/3]]],	# 1:[0/3,1/3]²
			[1/3,   [[1/3,2/3],[1/3,2/3]]],	# 1:[1/3,2/3]²
			[1/3,   [[2/3,3/3],[2/3,3/3]]],	# 1:[2/3,3/3]²
			[0, [[0,1],[0,1]]]			# 0:[0,1]²
		],

		# 12. Equi-diagonal, 10% noise
		[	[0.3,   [[0/3,1/3],[0/3,1/3]]],	# 1:[0/3,1/3]²
			[0.3,   [[1/3,2/3],[1/3,2/3]]],	# 1:[1/3,2/3]²
			[0.3,   [[2/3,3/3],[2/3,3/3]]],	# 1:[2/3,3/3]²
			[0.1, [[0,1],[0,1]]]			# 0:[0,1]²
		],

		# 13. Non-equi diagonal, no noise
		[	[0.4 * 10 / 9,   [[0/3,1/3],[0/3,1/3]]],	# 1:[0/3,1/3]²
			[0.3 * 10 / 9,   [[1/3,2/3],[1/3,2/3]]],	# 1:[1/3,2/3]²
			[0.2 * 10 / 9,   [[2/3,3/3],[2/3,3/3]]],	# 1:[2/3,3/3]²
			[0, [[0,1],[0,1]]]			# 0:[0,1]²
		],

		# 14. Non-equi diagonal, 10% noise
		[	[0.4,   [[0/3,1/3],[0/3,1/3]]],	# 1:[0/3,1/3]²
			[0.3,   [[1/3,2/3],[1/3,2/3]]],	# 1:[1/3,2/3]²
			[0.2,   [[2/3,3/3],[2/3,3/3]]],	# 1:[2/3,3/3]²
			[0.1, [[0,1],[0,1]]]			# 0:[0,1]²
		],

		# 15. X9, 10% noise
		[	[0.9/17,[[0/9,1/9],[0/9,1/9]]],	
		 	[0.9/17,[[1/9,2/9],[1/9,2/9]]],	
		 	[0.9/17,[[2/9,3/9],[2/9,3/9]]],	
		 	[0.9/17,[[3/9,4/9],[3/9,4/9]]],	
		 	[0.9/17,[[4/9,5/9],[4/9,5/9]]],	
		 	[0.9/17,[[5/9,6/9],[5/9,6/9]]],	
		 	[0.9/17,[[6/9,7/9],[6/9,7/9]]],	
		 	[0.9/17,[[7/9,8/9],[7/9,8/9]]],	
		 	[0.9/17,[[8/9,9/9],[8/9,9/9]]],	

		 	[0.9/17,[[0/9,1/9],[8/9,9/9]]],	
		 	[0.9/17,[[1/9,2/9],[7/9,8/9]]],	
		 	[0.9/17,[[2/9,3/9],[6/9,7/9]]],	
		 	[0.9/17,[[3/9,4/9],[5/9,6/9]]],	
		 	[0.9/17,[[5/9,6/9],[3/9,4/9]]],	
		 	[0.9/17,[[6/9,7/9],[2/9,3/9]]],	
		 	[0.9/17,[[7/9,8/9],[1/9,2/9]]],	
		 	[0.9/17,[[8/9,9/9],[0/9,1/9]]],	

			[0.1, [[0,1],[0,1]]]		
		],

		# 16. X5, 10% noise
		[	[0.9/9,[[0/5,1/5],[0/5,1/5]]],	
		 	[0.9/9,[[1/5,2/5],[1/5,2/5]]],	
		 	[0.9/9,[[2/5,3/5],[2/5,3/5]]],	
		 	[0.9/9,[[3/5,4/5],[3/5,4/5]]],	
		 	[0.9/9,[[4/5,5/5],[4/5,5/5]]],	

		 	[0.9/9,[[0/5,1/5],[4/5,5/5]]],	
		 	[0.9/9,[[1/5,2/5],[3/5,4/5]]],	
		 	[0.9/9,[[3/5,4/5],[1/5,2/5]]],	
		 	[0.9/9,[[4/5,5/5],[0/5,1/5]]],	

			[0.1, [[0,1],[0,1]]]		
		],

		# 17. X5 with random weights, 0.1% noise
		[	[0.0964,[[0/5,1/5],[0/5,1/5]]],	
		 	[0.1482,[[1/5,2/5],[1/5,2/5]]],	
		 	[0.0392,[[2/5,3/5],[2/5,3/5]]],	
		 	[0.0518,[[3/5,4/5],[3/5,4/5]]],	
		 	[0.0767,[[4/5,5/5],[4/5,5/5]]],	

		 	[0.1954,[[0/5,1/5],[4/5,5/5]]],	
		 	[0.0681,[[1/5,2/5],[3/5,4/5]]],	
		 	[0.1246,[[3/5,4/5],[1/5,2/5]]],	
		 	[0.1986,[[4/5,5/5],[0/5,1/5]]],	

			[0.001, [[0,1],[0,1]]]		
		],

		# 18. X9 with Zipf weights, 0.1% noise
		[	[0.2861,[[0/9,1/9],[0/9,1/9]]],	
		 	[0.1431,[[1/9,2/9],[1/9,2/9]]],	
		 	[0.0954,[[2/9,3/9],[2/9,3/9]]],	
		 	[0.0715,[[3/9,4/9],[3/9,4/9]]],	
		 	[0.0572,[[4/9,5/9],[4/9,5/9]]],	
		 	[0.0477,[[5/9,6/9],[5/9,6/9]]],	
		 	[0.0409,[[6/9,7/9],[6/9,7/9]]],	
		 	[0.0358,[[7/9,8/9],[7/9,8/9]]],	
		 	[0.0318,[[8/9,9/9],[8/9,9/9]]],	

		 	[0.0286,[[0/9,1/9],[8/9,9/9]]],	
		 	[0.0260,[[1/9,2/9],[7/9,8/9]]],	
		 	[0.0238,[[2/9,3/9],[6/9,7/9]]],	
		 	[0.0220,[[3/9,4/9],[5/9,6/9]]],	
		 	[0.0204,[[5/9,6/9],[3/9,4/9]]],	
		 	[0.0191,[[6/9,7/9],[2/9,3/9]]],	
		 	[0.0179,[[7/9,8/9],[1/9,2/9]]],	
		 	[0.0168,[[8/9,9/9],[0/9,1/9]]],	

			[0.0159, [[0,1],[0,1]]]		
		],

		# 19. X9 with randomly permuted Zipf weights, 0.1% noise
		[	[0.0477,[[0/9,1/9],[0/9,1/9]]],	
		 	[0.0572,[[1/9,2/9],[1/9,2/9]]],	
		 	[0.1431,[[2/9,3/9],[2/9,3/9]]],	
		 	[0.0204,[[3/9,4/9],[3/9,4/9]]],	
		 	[0.0168,[[4/9,5/9],[4/9,5/9]]],	
		 	[0.0191,[[5/9,6/9],[5/9,6/9]]],	
		 	[0.0238,[[6/9,7/9],[6/9,7/9]]],	
		 	[0.0715,[[7/9,8/9],[7/9,8/9]]],	
		 	[0.2861,[[8/9,9/9],[8/9,9/9]]],	

		 	[0.0954,[[0/9,1/9],[8/9,9/9]]],	
		 	[0.0179,[[1/9,2/9],[7/9,8/9]]],	
		 	[0.0286,[[2/9,3/9],[6/9,7/9]]],	
		 	[0.0409,[[3/9,4/9],[5/9,6/9]]],	
		 	[0.0220,[[5/9,6/9],[3/9,4/9]]],	
		 	[0.0260,[[6/9,7/9],[2/9,3/9]]],	
		 	[0.0318,[[7/9,8/9],[1/9,2/9]]],	
		 	[0.0358,[[8/9,9/9],[0/9,1/9]]],	

			[0.0159, [[0,1],[0,1]]]		
		],

		# 20. 5-equi-diagonal, 10% noise
		[	[0.9/5,   [[0/5,1/5],[0/5,1/5]]],	# 1:[0/5,1/5]²
		 	[0.9/5,   [[1/5,2/5],[1/5,2/5]]],	# 2:[1/5,2/5]²
		 	[0.9/5,   [[2/5,3/5],[2/5,3/5]]],	# 3:[2/5,3/5]²
		 	[0.9/5,   [[3/5,4/5],[3/5,4/5]]],	# 4:[3/5,4/5]²
		 	[0.9/5,   [[4/5,5/5],[4/5,5/5]]],	# 5:[4/5,5/5]²
			[0.1, [[0,1],[0,1]]]		
		],
		
		# 21. X3, 10% noise
		[	[0.9/5,[[0/3,1/3],[0/3,1/3]]],	
		 	[0.9/5,[[1/3,2/3],[1/3,2/3]]],	
		 	[0.9/5,[[2/3,3/3],[2/3,3/3]]],	
		 	[0.9/5,[[0/3,1/3],[2/3,3/3]]],	
		 	[0.9/5,[[2/3,3/3],[0/3,1/3]]],	

			[0.1, [[0,1],[0,1]]]		
		],

		# 22. Plus5, 10% noise
		[	[0.5, [[0/5,5/5], [2/5,3/5]]],
			[0.2, [[2/5,3/5], [0/5,2/5]]],
			[0.2, [[2/5,3/5], [3/5,5/5]]],
			[0.1, [[0,1],[0,1]]]], 

		# 23. Inverted Plus5, 10% noise
		[	[0.9/4, [[0/5,2/5], [0/5,2/5]]],
			[0.9/4, [[0/5,2/5], [3/5,5/5]]],
			[0.9/4, [[3/5,5/5], [0/5,2/5]]],
			[0.9/4, [[3/5,5/5], [3/5,5/5]]],
			[0.1, [[0,1],[0,1]]]], 

		# 24. Mod3-9x9, 10% noise
		[	[0.9/27, [[0/9,1/9], [0/9,1/9]]],
		 	[0.9/27, [[0/9,1/9], [3/9,4/9]]],
		 	[0.9/27, [[0/9,1/9], [6/9,7/9]]],

		 	[0.9/27, [[1/9,2/9], [1/9,2/9]]],
		 	[0.9/27, [[1/9,2/9], [4/9,5/9]]],
		 	[0.9/27, [[1/9,2/9], [7/9,8/9]]],

		 	[0.9/27, [[2/9,3/9], [2/9,3/9]]],
		 	[0.9/27, [[2/9,3/9], [5/9,6/9]]],
		 	[0.9/27, [[2/9,3/9], [8/9,9/9]]],

		 	[0.9/27, [[3/9,4/9], [0/9,1/9]]],
		 	[0.9/27, [[3/9,4/9], [3/9,4/9]]],
		 	[0.9/27, [[3/9,4/9], [6/9,7/9]]],

		 	[0.9/27, [[4/9,5/9], [1/9,2/9]]],
		 	[0.9/27, [[4/9,5/9], [4/9,5/9]]],
		 	[0.9/27, [[4/9,5/9], [7/9,8/9]]],

		 	[0.9/27, [[5/9,6/9], [2/9,3/9]]],
		 	[0.9/27, [[5/9,6/9], [5/9,6/9]]],
		 	[0.9/27, [[5/9,6/9], [8/9,9/9]]],

		 	[0.9/27, [[6/9,7/9], [0/9,1/9]]],
		 	[0.9/27, [[6/9,7/9], [3/9,4/9]]],
		 	[0.9/27, [[6/9,7/9], [6/9,7/9]]],

		 	[0.9/27, [[7/9,8/9], [1/9,2/9]]],
		 	[0.9/27, [[7/9,8/9], [4/9,5/9]]],
		 	[0.9/27, [[7/9,8/9], [7/9,8/9]]],

		 	[0.9/27, [[8/9,9/9], [2/9,3/9]]],
		 	[0.9/27, [[8/9,9/9], [5/9,6/9]]],
		 	[0.9/27, [[8/9,9/9], [8/9,9/9]]],

			[0.1, [[0,1],[0,1]]]], 

		# 25. Mod3-9x9, 10% noise
		[	[1.0/27, [[0/9,1/9], [0/9,1/9]]],
		 	[1.0/27, [[0/9,1/9], [3/9,4/9]]],
		 	[1.0/27, [[0/9,1/9], [6/9,7/9]]],

		 	[1.0/27, [[1/9,2/9], [1/9,2/9]]],
		 	[1.0/27, [[1/9,2/9], [4/9,5/9]]],
		 	[1.0/27, [[1/9,2/9], [7/9,8/9]]],

		 	[1.0/27, [[2/9,3/9], [2/9,3/9]]],
		 	[1.0/27, [[2/9,3/9], [5/9,6/9]]],
		 	[1.0/27, [[2/9,3/9], [8/9,9/9]]],

		 	[1.0/27, [[3/9,4/9], [0/9,1/9]]],
		 	[1.0/27, [[3/9,4/9], [3/9,4/9]]],
		 	[1.0/27, [[3/9,4/9], [6/9,7/9]]],

		 	[1.0/27, [[4/9,5/9], [1/9,2/9]]],
		 	[1.0/27, [[4/9,5/9], [4/9,5/9]]],
		 	[1.0/27, [[4/9,5/9], [7/9,8/9]]],

		 	[1.0/27, [[5/9,6/9], [2/9,3/9]]],
		 	[1.0/27, [[5/9,6/9], [5/9,6/9]]],
		 	[1.0/27, [[5/9,6/9], [8/9,9/9]]],

		 	[1.0/27, [[6/9,7/9], [0/9,1/9]]],
		 	[1.0/27, [[6/9,7/9], [3/9,4/9]]],
		 	[1.0/27, [[6/9,7/9], [6/9,7/9]]],

		 	[1.0/27, [[7/9,8/9], [1/9,2/9]]],
		 	[1.0/27, [[7/9,8/9], [4/9,5/9]]],
		 	[1.0/27, [[7/9,8/9], [7/9,8/9]]],

		 	[1.0/27, [[8/9,9/9], [2/9,3/9]]],
		 	[1.0/27, [[8/9,9/9], [5/9,6/9]]],
		 	[1.0/27, [[8/9,9/9], [8/9,9/9]]],

			[0.0, [[0,1],[0,1]]]], 
	];
	

	# Uncomment distributions
	$distributions->[0] = undef;
	$distributions->[1] = undef;
	$distributions->[3] = undef;
	#$distributions->[4] = undef;
	$distributions->[5] = undef;
	$distributions->[7] = undef;
	$distributions->[9] = undef;
	$distributions->[10] = undef;
	$distributions->[11] = undef;
	$distributions->[13] = undef;
	$distributions->[14] = undef;
	$distributions->[17] = undef;
	$distributions->[18] = undef;
	$distributions->[19] = undef;

	# Include
	#$distributions->[2] = undef;
	#$distributions->[6] = undef;
	#$distributions->[8] = undef;
	#$distributions->[12] = undef;
	#$distributions->[15] = undef;
	#$distributions->[16] = undef;
	#$distributions->[20] = undef;
	#$distributions->[21] = undef;

	# Process each sample size
	for (my $s = 0; $s <= $#$samples; ++$s) {
		my $sample = $samples->[$s];

		# Process each distribution
		for (my $d = 0; $d <= $#$distributions; ++$d) {
			# Skip loop if file exists
			my $file = "ehpm/ehpm-$d-$sample.eps";
			if (-r $file) {
				print "skipping $file because it already exists\n";
				next();
			}

			# Skip loop if distribution is undefined
			my $distribution = $distributions->[$d];
			if (! defined($distribution)) {
				print "skipping $file because distribution is undefined\n";
				next();
			}

			# Find distribution
			my $maxweight = 1;
			foreach my $p (@$distribution) {
				$maxweight = $p->[0] if ($p->[0] > $maxweight);
			}
			my $true = $hierarchy->wcover2sub($distribution);

			# Repeat learning experiment specified number of times
			my $L1 = 0;
			my $L2 = 0;
			my $L1sqr = 0;
			my $L2sqr = 0;
			my ($MLP, $MLPsqr, $nbetter) = (0, 0, 0);
			my $covers = {};
			my $allcovers = [];
			for (my $r = 0; $r < $repeat; ++$r) {
				# Print sample
				my $date = `date`;
				chomp($date);
				print "\n\n" . ("=" x 80) . "\n$file: $r ($date)\n"
					. ("=" x 80) .  "\n\n";

				# Create data from true distribution
				my $data = $hierarchy->random($distribution, $sample);

				# Create EHPM
				my $ehpm = DTAG::Learner::EHPM->new($hierarchy, $prior, 5);
				$ehpm->mindata(5);

				# Learn distribution
				$ehpm->learn7($data, $true, scalar(@$distribution));

				# Compute L1 and L2 errors
				my $errorL1 = $ehpm->errorLn($ehpm->cover(), $true, 1);
				my $errorL2 = $ehpm->errorLn($ehpm->cover(), $true, 2);
				$L1 += $errorL1;
				$L2 += $errorL2;
				$L1sqr += $errorL1 ** 2;
				$L2sqr += $errorL2 ** 2;
				print "    L1=$L1 L2=$L2\n";
				$ehpm->var('errorL1', $errorL1);
				$ehpm->var('errorL2', $errorL2);

				# Compute relative mlogp error
				my $error_mlogp 
					= $ehpm->var('mlogp') - $ehpm->var('true_mlogp');
				$ehpm->var('error_mlogp', $error_mlogp);
				$MLP += $error_mlogp;
				$MLPsqr += $error_mlogp ** 2;
				$nbetter += 1 if ($error_mlogp <= 0);

				# Save data and induced distribution
				my $coverid = $ehpm->cover_id();
				$covers->{$coverid} = [] if (! $covers->{$coverid});
				push @{$covers->{$coverid}}, $ehpm;
				push @{$allcovers}, $ehpm;

				# Print induced distribution
				print $ehpm->print();
			}

			# Compute statistics for learning experiment
			$L1 = $L1 / $repeat;
			$L2 = $L2 / $repeat;
			$MLP = $MLP / $repeat;
			my $VarL1 = sqrt(abs(($L1sqr / $repeat) - $L1 * $L1));
			my $VarL2 = sqrt(abs(($L2sqr / $repeat) - $L2 * $L2));
			my $VarMLP = sqrt(abs(($MLPsqr / $repeat) - $MLP * $MLP));
			my @covers_sorted = sort 
				{$#{$covers->{$a}} <=> $#{$covers->{$b}}} keys(%$covers);
			my @allcovers_sorted = sort 
				{$a->var('errorL2') <=> $b->var('errorL2')} @$allcovers;

			# Compute median cover (50%), when covers are sorted by probability
			my $ehpm = $allcovers_sorted[int($repeat / 2)];
			
			# Print statistics
			my $statistics = "% Statistics\n" 
				. "samples     = $repeat\n"
				. "E(L1)       = $L1\n"
				. "Var(L1)     = $VarL1\n"
				. "E(L2)       = $L2\n"
				. "Var(L2)     = $VarL2\n"
				. "E(MLPerr)   = $MLP\n"
				. "Var(MLPerr) = $VarMLP\n"
				. "E(MLPerr<=0) = $nbetter/$repeat\n" 
				. "\n% Covers sorted by frequency\n"
				. join("\n", 
					map {
						"$_: count=" . scalar(@{$covers->{$_}})
							. " freq=" 
							.  (scalar(@{$covers->{$_}}) / $repeat)
					} @covers_sorted)
				. "\n\n% EHPM covers sorted by L2 error\n"
				. join("\n", 
					map {
						$_->print()
						. ": errorL2=" . $_->var("errorL2")
						. " errorL1=" . $_->var("errorL1")
						. " errorMLP =" . $_->var('error_mlogp')
						. "\n"}
					 @allcovers_sorted);


			# Print most frequent cover and statistics
			$ehpm->save_ps($file, 
				'%%BoundingBox: 0 0 480 100', 
					$ehpm->ps_dist($true),
					"120 0 translate\n", $ehpm->ps_data(),
					"120 0 translate\n", $ehpm->ps_dist(),
					"120 0 translate\n", $ehpm->ps_boxes_colour(),
					"\n% Parameter settings\n",
					"(" . $ehpm->print() 
						. "\n\n$statistics\n) pop\n"
				);

			# Print statistics
			print "\n\n$statistics\n\n";
		}
	}
}


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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::Bayesian -- DTAG class for computing Bayesian priors

=cut

# --------------------------------------------------

package DTAG::Learner::Bayesian;
use strict;




## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/fmodel.pl
## ------------------------------------------------------------

# fmodel($distribution, $ndata) = $prob: compute probability of model
sub fmodel {
	my $self = shift;
	my $dist = shift;
	my $ndata = shift;

	# Maximum likelihood estimation: all models are equiprobable
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/logfmodel.pl
## ------------------------------------------------------------

# logfmodel($ndist, $ndata) = $prob: compute probability of model
sub logfmodel {
	my $self = shift;

	# Maximum likelihood estimation: all models are equiprobable
	return log($self->fmodel(@_));
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/new.pl
## ------------------------------------------------------------

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Return new object
	return $self;
}

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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/MDL/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::Bayesian::MDL 
	-- DTAG class for computing Bayesian priors based on minimum
	   description length.

=cut

# --------------------------------------------------

package DTAG::Learner::Bayesian::MDL;
use strict;

# Set super class
use base 'DTAG::Learner::Bayesian';


## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/MDL/delta.pl
## ------------------------------------------------------------

# $self->delta($cover1, $cover2): compute increase in -logp by
# going from $cover1 to $cover2
sub delta {
	my $self = shift;
	my $cover1 = shift;
	my $cover2 = shift;

	# Compute -logp of $cover1
	my $mlogp1 = 
		scalar(@$cover1) 
			? $self->cost($cover1)
			: 0;

	# Compute -logp of $cover2
	my $mlogp2 = 
		scalar(@$cover2) 
			? $self->cost($cover2)
			: 0;

	# Return difference
	return $mlogp2 - $mlogp1;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/MDL/fmodel.pl
## ------------------------------------------------------------

# fmodel($ndist, $ndata) = $prob: compute probability of model
sub fmodel {
	my $self = shift;

	# Compute parameter description length
	return exp($self->logfmodel(@_));
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Bayesian/MDL/logfmodel.pl
## ------------------------------------------------------------

# logfmodel($nfree, $ndata) = $prob: compute probability of model
sub logfmodel {
	my $self = shift;
	my $nfree = shift;
	my $ndata = shift;

	# Compute parameter description length
	#my $lM = ($ndist-1) / 2 * log($ndata || 1) / log(2);

	# Compute Bayesian prior probability
	#return - $lM * log(2);
	#return ($ndist - 1) * log($ndata || 1) / 2;
	return $nfree * log($ndata || 1) / 2;
}

1;

1;
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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::Data
	-- DTAG class representing data sets
=cut

# --------------------------------------------------

package DTAG::Learner::Data;
use strict;


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/add.pl
## ------------------------------------------------------------

# $self->add($outcome, ...) = $self: add outcomes to list of outcomes

sub add {
	my $self = shift;

	# Add outcomes to outcome list, and add outcome ID to data
	push @{$self->outcomes()}, @_;
	push @{$self->data()}, scalar(@{$self->outcomes()}) - 1;

	# Return self
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/clone.pl
## ------------------------------------------------------------

# $self->clone() = $clone: clone data set

sub clone {
	my $self = shift;

	# Create clone
	my $clone = $self->new();

	# Set outcomes in clone
	$clone->outcomes($self->outcomes());
	$clone->data($self->data());

	# Return clone
	return $clone;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/count.pl
## ------------------------------------------------------------

# $self->count() = $count: compute number of observations in data set

sub count {
	my $self = shift;

	# Return number of data
	return scalar(@{$self->data()});
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/data.pl
## ------------------------------------------------------------

sub data {
	my $self = shift;
	
	# Set outcomes
	$self->{'data'} = shift if (@_);

	# Get outcomes
	return $self->{'data'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/del.pl
## ------------------------------------------------------------

# $self->del($datum, ...): delete outcomes from data multi-set

sub del {
	my $self = shift;
	my $data = $self->data();

	# Delete each given outcome
	foreach my $datum (@_) {
		# Find offset of first outcome that matches $outcome
		my $offset = scalar(@$data) - 1;
		while ($offset >= 0 && $data->{$offset} ne $datum) {
			++$offset;
		}

		# Delete outcome at offset, if offset is legal
		splice(@$data, $offset, 1)
			if ($offset >= 0);
	}

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/graph.pl
## ------------------------------------------------------------


sub graph {
	my $self = shift;
	my $datum = shift;

	# Die because method isn't implemented
	die "Method graph() not implemented in class " . (ref($self) || "?");
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/new.pl
## ------------------------------------------------------------

#	Create new data object: Data->new() = $data

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# create new object and bless it into new class
	my $self = {'outcomes' => [], 'data' => []}; 
	bless ($self, $class);

	# return new object
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/node.pl
## ------------------------------------------------------------


sub node {
	my $self = shift;
	my $datum = shift;

	# Die because method isn't implemented
	die "Method node() not implemented in class " . (ref($self) || "?");
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/observations.pl
## ------------------------------------------------------------

sub observations {
	my $self = shift;
	
	# Set observations
	$self->{'data'} = shift if (@_);

	# Get observations
	return $self->{'data'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/outcome.pl
## ------------------------------------------------------------

sub outcome {
	my $self = shift;
	my $datum = shift;
	return $self->outcomes()->[$datum];
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/outcomes.pl
## ------------------------------------------------------------

sub outcomes {
	my $self = shift;
	
	# Set outcomes
	$self->{'outcomes'} = shift if (@_);

	# Get outcomes
	return $self->{'outcomes'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/partition.pl
## ------------------------------------------------------------

# $self->partition($class) = [$inside, $outside]

sub partition {
	my $self = shift;
	my $hierarchy = shift;
	my $class = shift;

	# Create new data sets 
	my $inside  = $self->clone();
	my $outside = $self->clone();
	my $data = $self->data(); 
	my $dataIn  = $inside ->data([]);
	my $dataOut = $outside->data([]);

	# Partition data 
	foreach my $o (@$data) {
		if ($hierarchy->isa($o, $class)) {
			push @$dataIn, $o;
		} else {
			push @$dataOut, $o;
		}
	}

	# Return list of new data sets
	return [$inside, $outside];
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/plane.pl
## ------------------------------------------------------------

sub plane {
	my $self = shift;
	$self->{'plane'} = shift if (@_);
	return $self->{'plane'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/print.pl
## ------------------------------------------------------------

sub print {
	my $self = shift;
	
	my $i = -1;
	return ref($self) . "\noutcomes:\n" 
		. join("\n", map {++$i; "$i=" . DTAG::Interpreter::dumper($_)} @{$self->outcomes()}) . "\n"
		. "\n\ndata: "
		. join(" ", @{$self->data()}) . "\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/space.pl
## ------------------------------------------------------------

sub space {
	my $self = shift;
	$self->{'space'} = shift if (@_);
	return $self->{'space'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/var.pl
## ------------------------------------------------------------

sub var {
	my $self = shift;
	my $var = shift;
	$self->{$var} = shift if (@_);
	return $self->{$var};
}

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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/GraphData/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::Data::GraphData
	-- data sets given by a graph
	
=cut

# --------------------------------------------------

package DTAG::Learner::Data::GraphData;
use strict;

# Specify super class
use base 'DTAG::Learner::Data';


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/GraphData/graph.pl
## ------------------------------------------------------------

# $self->graph($outcome) = $graph

sub graph {
	my $self = shift;
	return $self->{'graph'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/GraphData/new.pl
## ------------------------------------------------------------

sub new {
	# Call super constructor 
	my $proto = shift;
	my $new = DTAG::Learner::Data::new($proto);

	# Read arguments
	my $graph = $new->{'graph'} = shift;

	# Add all non-comment nodes as outcomes
	my $outcomes = $new->outcomes([]);
	my $size = $graph->size();
	for (my $i = 0; $i < $size; ++$i) {
		push @$outcomes, $i
			if (! $graph->node($i)->comment());
	}

	# Return new data set
	return $new;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/GraphData/node.pl
## ------------------------------------------------------------

# $self->node($outcome) = $node

sub node {
	my $self = shift;
	return shift;
}

1;
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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/RandomData/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::RandomData
	-- data sets given randomly
	
=cut

# --------------------------------------------------

package DTAG::Learner::RandomData;
use strict;

# Specify super class
use base 'DTAG::Learner::Data';


## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/RandomData/generate.pl
## ------------------------------------------------------------

sub generate {
	my $self = shift;
	my $density = shift;
	my $dim = shift;
	my $n = shift || 0;
	my $seed = shift;

	# Seed random generator, if requested
	srand($seed) if ($seed);

	# Generate random outcomes
	my $data = $self->{'data'} = [];
	my $outcomes = $self->{'outcomes'} = [];
	my $i = 0;
	while ($i < $n) {
		# Generate random vector with uniform distribution
		my $x = $self->generate_uniform($dim);

		# Only include $x in the data set if density of $x > a random
		# number in [0,1]
		if (&$density($x) > rand()) {
			$self->add($x);
			++$i;
		}
	}

	# Return
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/RandomData/generate_uniform.pl
## ------------------------------------------------------------

sub generate_uniform {
	my $self = shift;
	my $dim = shift;

	# Generate uniformly distributed random vector
	my $x = [];
	for (my $i = 0; $i < $dim; ++$i) {
		push @$x, rand();
	}

	# Return random vector
	return $x;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Data/RandomData/new.pl
## ------------------------------------------------------------

sub new {
	# Call super constructor 
	my $proto = shift;
	my $new = DTAG::Learner::Data::new($proto);

	# Generate random outcomes
	$new->generate(@_);
	
	# Return new data set
	return $new;
}

1;

1;
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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::Distribution - distribution on graphs

=head1 DESCRIPTION


=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Learner::Distribution;
use strict;



## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/f.pl
## ------------------------------------------------------------

sub f {
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/learn.pl
## ------------------------------------------------------------

sub learn {
	my $self = shift;
	my $data = shift;
	my $bayesian = shift;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/logf.pl
## ------------------------------------------------------------

sub logf {
	my $self = shift;
	my $fx = $self->f(shift);
	return ($fx > 0) ? log($fx) : 1e200;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/loglikelihood.pl
## ------------------------------------------------------------

sub mlog_likelihood {
	my $self = shift;
	my $data = shift;
	my $mlogL = 0;

	# Process data
	foreach my $d (@{$data->data()}) {
		$mlogL -= $self->logf($data->outcomes()->[$d]);
	}

	# Return
	return $mlogL;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/mindata.pl
## ------------------------------------------------------------

sub mindata {
	my $self = shift;
	$self->{'mindata'} = shift if (@_);
	return $self->{'mindata'} || 5;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/new.pl
## ------------------------------------------------------------

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Initialize
	$self->mindata(1);

	# Return new object
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/var.pl
## ------------------------------------------------------------

sub var {
	my $self = shift;
	my $var = shift;
	$self->{$var} = shift if (@_);
	return $self->{$var};
}
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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::EHPM
	
=cut

# --------------------------------------------------

package DTAG::Learner::EHPM;
use strict;

# Specify super class
use base 'DTAG::Learner::Distribution';

# Specify default posterior function of partition
my $mlog_posterior_function = sub {
	my $self = shift;
	my $partition = shift;

	# Return Minimum Description Length posterior probability of partition
	return 
		$self->mlog_likelihood($partition)
		+ log($self->total() || 1) / 2;
};


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/cover.pl
## ------------------------------------------------------------

# $cover = [$class, [$cover1, ..., $coverN]]

sub cover {
	my $self = shift;
	$self->{'cover'} = shift if (@_);
	return $self->{'cover'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/cover_id.pl
## ------------------------------------------------------------

sub cover_id {
	my $self = shift;
	my $cover = shift || $self->cover();

	return join(" ", 
		map {$self->hierarchy()->print_box($_->space_box())}
			@$cover);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/delta.pl
## ------------------------------------------------------------

sub delta {
	my $self = shift;
	my $cover1 = shift;
	my $cover2 = shift;

	# Return difference in minus-log posterior probability
	return $self->mlog_posterior($cover2) - $self->mlog_posterior($cover1);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/delta_function.pl
## ------------------------------------------------------------

sub delta_function {
	my $self = shift;
	$self->{'delta_function'} = shift() if (@_);
	return $self->{'delta_function'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/errorLn.pl
## ------------------------------------------------------------

sub errorLn {
	my $self = shift;
	my $cover = shift;
	my $true = shift;
	my $exp = shift || 2;

	# Compute Ln error norm for estimate given by $cover for $true
	my $n = 100;
	my $sum = 0;
	for (my $i = 0.5; $i < $n; ++$i) {
		for (my $j = 0.5; $j < $n; ++$j) {
			my $x = [$i / $n, $j / $n];
			my $truevalue = &$true($x);
			my $estvalue = $self->f($x, $cover);
			$sum += abs($truevalue-$estvalue) ** $exp;
		}
	}

	# Return Ln norm
	return ($sum / ($n * $n))  ** (1 / $exp);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/f.pl
## ------------------------------------------------------------

sub f {
	my $self = shift;
	my $x = shift;
	my $cover = shift || $self->cover();

	# Find partition containing $x
	my $partition = $self->find_partition($x, $cover);

	# Return f-value computed by that partition
	return $partition ? $partition->f($x, $self) : undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/find_partition.pl
## ------------------------------------------------------------

# $ehpm->find_partition($x) = $partition: find partition in ordered cover
# containing $x

sub find_partition {
	my $self = shift;
	my $x = shift;
	my $cover = shift || $self->cover();

	# Process ordered cover
	my $hierarchy = $self->hierarchy();
	foreach my $partition (@$cover) {
		return $partition 
			if $hierarchy->box_inside($partition->space_box(), $x);
	}

	# No partition contains $x
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/find_partition_index.pl
## ------------------------------------------------------------

# $ehpm->find_partition($x) = $partition: find partition in ordered cover
# containing $x

sub find_partition_index {
	my $self = shift;
	my $x = shift;
	my $cover = shift || $self->cover();

	# Process ordered cover
	my $hierarchy = $self->hierarchy();
	for (my $i = 0; $i <= $#$cover; ++$i) {
		my $partition = $cover->[$i];
		return $i
			if $hierarchy->box_inside($partition->space_box(), $x);
	}

	# No partition contains $x
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/hierarchy.pl
## ------------------------------------------------------------

sub hierarchy {
	my $self = shift;
	$self->{'hierarchy'} = shift if (@_);
	return $self->{'hierarchy'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/learn.pl
## ------------------------------------------------------------

sub learn {
	my $self = shift;
	my $data = shift;
	my $hierarchy = $self->hierarchy();

	# Create root partition
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);

	# Initialize cover
	$self->cover([$root]);

	# Improve cover by local search
	my $optimal = 0;
	my $changes = 0;
	while ((! $optimal) && $changes < 1000) {
		++$changes;

		# The current cover is optimal until proven otherwise
		my $opt_mlog_posterior = $self->mlog_posterior($self->cover());
		my $old_mlog_posterior = $opt_mlog_posterior;
		my $opt_cover = $self->cover();
		my $action = [0,[]];
		$optimal = 1;

		# Print current cover
		print "optimal cover: (" . join(", ", 
			map { join("x", 
					map { "[" . sprintf("%.4g", $_->[0]) . "," 
							. sprintf("%.4g", $_->[1]) . "]"
					} @{$_->space_box()})
			} @$opt_cover) . ") with posterior=$opt_mlog_posterior\n";
		print "counts: " . 
			join(" ", map {scalar(@{$_->data()->data()})} @$opt_cover)
				. "\n";

		# Find optimal partitionings of each class
		my $cover = $self->cover();
		for (my $i = 0; $i < scalar(@$cover); ++$i) {
			# Find optimal partitioning of the partition
			my $partition = $cover->[$i];
			my $partitioning = $partition->opt_partitioning()
				|| $partition->compute_opt_partitioning($self,
					[@$cover[0..$i-1]]);

			# Use the locally optimal partitioning, if it is better than the 
			# currently optimal cover
			if ($old_mlog_posterior + $partitioning->[0] 
					< $opt_mlog_posterior) {
				$optimal = 0;
				$opt_mlog_posterior = $old_mlog_posterior + $partitioning->[0];
				$opt_cover = $self->partitioning2cover($i, $partitioning);
				$action = [1, $partitioning, $i];
			}
		}
		
		# Find optimal mergings of each class
		for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
			# Compute optimal cover produced by merging and its weight
			my $merging = $self->merging($cover, $i, $old_mlog_posterior);

			# Use the merging of $i, if it is better than the
			# currently optimal cover
			if ($merging->[0] < $opt_mlog_posterior) {
				$optimal = 0;
				$opt_mlog_posterior = $merging->[0];
				$opt_cover = $merging->[1];
				$action = [2, $merging, $i];
			}
		}

		# Debug
		if ($action->[0] == 0) {
			print "    Action: exit\n";
		} elsif ($action->[0] == 1) {
			print "    Action: partitioning " 
				. $action->[2] . ": " 
				. $hierarchy->print_box($action->[1][2]->space_box()) 
				. " into " 
				. $hierarchy->print_box($action->[1][1]->space_box()) . "\n";
		} elsif ($action->[0] == 2) {
			print "    Action: merging "
				. $action->[2] . "\n";
		}
		 
		# Set optimal cover
		$self->cover($opt_cover);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/learn2.pl
## ------------------------------------------------------------

sub learn2 {
	my $self = shift;
	my $data = shift;
	my $hierarchy = $self->hierarchy();

	# Create root partition
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);

	# Initialize cover
	$self->cover([$root]);

	# Improve cover by local search
	my $optimal = 0;
	my $changes = 0;
	while ((! $optimal) && $changes < 1000) {
		++$changes;

		# The current cover is optimal until proven otherwise
		my $opt_mlog_posterior = $self->mlog_posterior($self->cover());
		my $old_mlog_posterior = $opt_mlog_posterior;
		my $opt_cover = $self->cover();
		my $action = [0,[]];
		$optimal = 1;

		# Print current cover
		print "cover=" . 
			$self->print_cover($opt_cover)
			. " counts=[" . 
				join(",", map {scalar(@{$_->data()->data()})} @$opt_cover)
				. "]"
			. " posterior=" .
				sprintf("%6g", $opt_mlog_posterior) . "\n"; 
		
		# Find optimal partitionings of each class
		my $cover = $self->cover();
		for (my $i = 0; $i < scalar(@$cover); ++$i) {
			# Find optimal partitioning of the partition
			my $partition = $cover->[$i];
			my $partitioning = $partition->opt_partitioning()
				|| $partition->compute_opt_partitioning2($self,
					[@$cover[0..$i-1]], [@$cover[($i+1)..$#$cover]]);

			# Use the locally optimal partitioning, if it is better than the 
			# currently optimal cover
			if ($partitioning && $old_mlog_posterior + $partitioning->[0] 
					< $opt_mlog_posterior) {
				$optimal = 0;
				$opt_mlog_posterior = $old_mlog_posterior + $partitioning->[0];
				$opt_cover = $partitioning->[1];
				$action = [1, $partitioning, $i];
			}
		}
		
		# Find optimal mergings of each class
		for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
			# Compute optimal cover produced by merging and its weight
			my $merging = $self->merging($cover, $i, $old_mlog_posterior);

			# Use the merging of $i, if it is better than the
			# currently optimal cover
			if ($merging->[0] < $opt_mlog_posterior) {
				$optimal = 0;
				$opt_mlog_posterior = $merging->[0];
				$opt_cover = $merging->[1];
				$action = [2, $merging, $i];
			}
		}

		# Reset optimal partitionings of affected partitions
		if ($action->[0] == 1) {
			# Partitioning: reset partition $i
			#my $partitioning = $action->[1];
			#foreach my $partition (@$partitioning[1..$#$partitioning]) {
			#	$partition->opt_partitioning(undef);
			#}
		} elsif ($action->[0] == 2) {
			# Merging: reset partitions $i, ... in $opt_cover
			for (my $i = $action->[2]; $i <= $#$opt_cover; ++$i) {
				$opt_cover->[$i]->opt_partitioning(undef);
			}
		}

		# Debug
		if ($action->[0] == 0) {
			print "    Action: exit\n";
		} elsif ($action->[0] == 1) {
			print "    Action: split " 
				. $self->print_cover($opt_cover) . "\n";
		} elsif ($action->[0] == 2) {
			print "    Action: merge"
				. $self->print_cover($opt_cover) . "\n";
		}

		# Sanitize optimal cover: include only partitions with more
		# than 

		# Set optimal cover
		$self->cover($opt_cover);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/learn3.pl
## ------------------------------------------------------------

sub learn3 {
	my $self = shift;
	my $data = shift;
	my $hierarchy = $self->hierarchy();

	# Create root partition
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);

	# Initialize cover
	$self->cover([$root]);

	# Improve cover by local search
	my $optimal = 0;
	my $changes = 0;
	while ((! $optimal) && $changes < 1000) {
		++$changes;

		# The current cover is optimal until proven otherwise
		my $opt_mlog_posterior = $self->mlog_posterior($self->cover());
		my $old_mlog_posterior = $opt_mlog_posterior;
		my $opt_cover = $self->cover();
		my $opt_moved = 0;
		my $action = [0,[]];
		$optimal = 1;

		# Print current cover
		print "cover=" . 
			$self->print_cover($opt_cover)
			. " counts=[" . 
				join(",", map {scalar(@{$_->data()->data()})} @$opt_cover)
				. "]"
			. " posterior=" .
				sprintf("%6g", $opt_mlog_posterior) . "\n"; 

		# Merge partitions with fewer than $mindata observations
		my $cover = $self->cover();
		for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
			if ($cover->[$i]->count() < $self->mindata()) {
				# Compute optimal cover produced by merging and its weight
				my $merging = $self->merging($cover, $i, $old_mlog_posterior);

				# Use the merging of $i
				if (defined($merging->[1])) {
					$optimal = 0;
					$opt_mlog_posterior = -1e100;
					$opt_cover = $merging->[1];
					$action = [2, $merging, $i];
				}
			}
		}
		
		# Find optimal partitionings of each class
		if ($optimal) {
			for (my $i = 0; $i < scalar(@$cover); ++$i) {
				# Find optimal partitioning of the partition
				my $partition = $cover->[$i];
				my $partitioning = $partition->opt_partitioning()
					|| $partition->compute_opt_partitioning3($self,
						[@$cover[0..$i-1]], [@$cover[($i+1)..$#$cover]]);

				# Use the locally optimal partitioning, if it is better than the 
				# currently optimal cover
				#if ($partitioning && $old_mlog_posterior + $partitioning->[0] 
				#		< $opt_mlog_posterior) {
				if ($partitioning && $partitioning->[0] < 0 
					&& $opt_moved < $partitioning->[2]) {
					$optimal = 0;
					$opt_mlog_posterior = $old_mlog_posterior 
						+ $partitioning->[0];
					$opt_moved = $partitioning->[2];
					$opt_cover = $partitioning->[1];
					$action = [1, $partitioning, $i];
				}
			}
		}
		
		# Find optimal mergings of each class
		if ($optimal) {
			for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
				# Compute optimal cover produced by merging and its weight
				my $merging = $self->merging($cover, $i, $old_mlog_posterior);

				# Use the merging of $i, if it is better than the
				# currently optimal cover
				if ($merging->[0] < $opt_mlog_posterior) {
					$optimal = 0;
					$opt_mlog_posterior = $merging->[0];
					$opt_cover = $merging->[1];
					$action = [2, $merging, $i];
				}
			}
		}

		# Reset optimal partitionings of affected partitions
		if ($action->[0] == 1) {
			# Partitioning: reset partition $i
			#my $partitioning = $action->[1];
			#foreach my $partition (@$partitioning[1..$#$partitioning]) {
			#	$partition->opt_partitioning(undef);
			#}
		} elsif ($action->[0] == 2) {
			# Merging: reset partitions $i, ... in $opt_cover
			for (my $i = $action->[2]; $i <= $#$opt_cover; ++$i) {
				$opt_cover->[$i]->opt_partitioning(undef);
			}
		}

		# Debug
		if ($action->[0] == 0) {
			print "    Action: exit\n";
		} elsif ($action->[0] == 1) {
			print "    Action: split " 
				. $self->print_cover($opt_cover) . "\n";
		} elsif ($action->[0] == 2) {
			print "    Action: merge"
				. $self->print_cover($opt_cover) . "\n";
		}

		# Sanitize optimal cover: include only partitions with more
		# than 

		# Set optimal cover
		$self->cover($opt_cover);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/learn4.pl
## ------------------------------------------------------------

sub learn4 {
	my $self = shift;
	my $data = shift;
	my $hierarchy = $self->hierarchy();

	# Create root partition
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);

	# Initialize cover
	$self->cover([$root]);

	# Improve cover by local search
	my $optimal = 0;
	my $changes = 0;
	while ((! $optimal) && $changes < 1000) {
		++$changes;

		# The current cover is optimal until proven otherwise
		my $opt_mlog_posterior = $self->mlog_posterior($self->cover());
		my $old_mlog_posterior = $opt_mlog_posterior;
		my $opt_cover = $self->cover();
		my $opt_moved = 0;
		my $action = [0,[]];
		$optimal = 1;

		# Print current cover
		print "cover=" . 
			$self->print_cover($opt_cover)
			. " counts=[" . 
				join(",", map {scalar(@{$_->data()->data()})} @$opt_cover)
				. "]"
			. " posterior=" .
				sprintf("%6g", $opt_mlog_posterior) . "\n"; 

		# Merge partitions with fewer than $mindata observations
		my $cover = $self->cover();
		for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
			if ($cover->[$i]->count() < $self->mindata()
				|| $cover->[$i]->count() < $self->total()
					* $cover->[$i]->prior_mass()) {
				# Compute optimal cover produced by merging and its weight
				my $merging = $self->merging($cover, $i, $old_mlog_posterior);

				# Use the merging of $i
				if (defined($merging->[1])) {
					$optimal = 0;
					$opt_mlog_posterior = -1e100;
					$opt_cover = $merging->[1];
					$action = [2, $merging->[1], $i];
				}
			}
		}
		
		if ($optimal) {
			# Find optimal partitionings of each class
			for (my $i = 0; $i < scalar(@$cover); ++$i) {
				# Find optimal partitioning of the partition
				print "    Partitioning $i\n";
				my $partition = $cover->[$i];
				my $partitioning = $partition->opt_partitioning()
					|| $partition->compute_opt_partitioning4($self,
						[@$cover[0..$i-1]], [@$cover[($i+1)..$#$cover]]);

				# Use the locally optimal partitioning, if it is
				# better than the currently optimal cover
				if ($partitioning
						&& $partitioning->[0] + $old_mlog_posterior 
							< $opt_mlog_posterior) {
					$opt_mlog_posterior = $old_mlog_posterior 
						+ $partitioning->[0];
					$opt_moved = $partitioning->[2];
					$opt_cover = $partitioning->[1];
					$action = [1, $partitioning, $i, $opt_moved];
					$optimal = 0;
				}
			}
		
			# Find optimal mergings of each class
			for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
				# Compute optimal cover produced by merging and its weight
				my $merging = $self->merging($cover, $i, $old_mlog_posterior);

				# Use the merging of $i, if it is better than the
				# currently optimal cover
				if ($merging->[0] < $opt_mlog_posterior) {
					$opt_mlog_posterior = $merging->[0];
					$opt_cover = $merging->[1];
					$action = [2, $merging, $i];
					$optimal = 0;
				}
			}
		}

		# Reset optimal partitionings of affected partitions
		if ($action->[0] == 1) {
			# Partitioning: reset partition $i
			#my $partitioning = $action->[1];
			#foreach my $partition (@$partitioning[1..$#$partitioning]) {
			#	$partition->opt_partitioning(undef);
			#}
		} elsif ($action->[0] == 2) {
			# Merging: reset partitions $i, ... in $opt_cover
			for (my $i = $action->[2]; $i <= $#$opt_cover; ++$i) {
				$opt_cover->[$i]->opt_partitioning(undef);
			}
		}

		# Debug
		if ($action->[0] == 0) {
			print "    Action: exit\n";
		} elsif ($action->[0] == 1) {
			print "    Action: split " 
				. $self->print_cover($opt_cover) . " moved=" 
					. $action->[3] . "\n";
		} elsif ($action->[0] == 2) {
			print "    Action: merge"
				. $self->print_cover($opt_cover) . "\n";
		}

		# Set optimal cover
		$self->cover($opt_cover);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/learn5.pl
## ------------------------------------------------------------

sub learn5 {
	my $self = shift;
	my $data = shift;
	my $hierarchy = $self->hierarchy();

	# Create root partition
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);
	$self->cover([$root]);
	
	# Create cover hash with visited covers
	my $visited = {};

	# Initialize states
	my $state = [$self->mlog_posterior($self->cover()), 
		$self->cover(), 'root'];
	my $lstate = $state; 
	my $gstate = undef;

	# Initialize depths and changes
	my $depth = 0;
	my $maxdepth = 30;
	my $changes = 0;

	# Improve cover by local search
	while ($depth < $maxdepth && defined($lstate)) {
		# Increment depth and changes
		++$depth;
		++$changes;
		my $skip = 0;
		my $mlogp_old = $lstate->[0];
		my $cover = $lstate->[1];
		$visited->{$self->print_cover($cover)} += 1;

		# Print current cover
		print $self->print_cover2(
			($depth > 1 ? "DEPTH $depth: " : ""),
			$cover, 
			$lstate->[0]);

		# Reset locally optimal cover
		$lstate = undef;

		# Merge partitions with fewer than $mindata observations
		for (my $i = 0; $i < $#$cover; ++$i) {
			if ($cover->[$i]->count() < $self->mindata()
					|| $cover->[$i]->count() < $self->total()
						* $cover->[$i]->prior_mass()) {
				# Compute optimal cover produced by merging and its weight
				my $mstate = $self->merge($cover, $i);

				# Use the merging of $i, unless previously visited
				if ($mstate && $mstate->[1]) {
					if ($visited->{$self->print_cover($mstate->[1])}) {
						print $self->print_cover2("REJECTED merge!", 
							$mstate->[1], $mstate->[0]);
					} else {
						$lstate = [-1e100, $mstate->[1], "merge! $i"];
						$skip = 1;
						last();
					}
				}
			}
		}
		
		# Proceed with partitions and mergings, unless asked to skip
		if (! $skip) {
			# Find optimal partitionings of each class
			for (my $i = 0; $i <= $#$cover; ++$i) {
				# Debug
				print "    Partitioning $i\n";

				# Find optimal partitioning of the partition
				my $partition = $cover->[$i];
				my $pstate = $partition->opt_partitioning()
					|| $partition->compute_opt_partitioning5($self,
						[@$cover[0..$i-1]], [@$cover[($i+1)..$#$cover]],
						$mlogp_old);

				# Use partitioning if better than $lstate
				if ($pstate && $pstate->[1] && (((! $lstate) 
						|| $pstate->[0] + $state->[0] < $lstate->[0]))) {
					if (($visited->{$self->print_cover($pstate->[1])} 
							|| 0) > 1) {
						print $self->print_cover2("REJECTED split $i", 
							$pstate->[1], $pstate->[0]);
					} else {
						$lstate = [$pstate->[0] + $state->[0],
							$pstate->[1], "split $i"];
					}
				}
			}
		
			# Find optimal mergings of each class
			for (my $i = 0; $i < $#$cover; ++$i) {
				# Compute optimal cover produced by merging and its weight
				my $mstate = $self->merging2($cover, $i);

				# Use merging if better than $lstate
				if ($mstate && $mstate->[1] 
						&& ((! $lstate) || $mstate->[0] < $lstate->[0])) {
					if ($visited->{$self->print_cover($mstate->[1])}) {
						print $self->print_cover2("REJECTED merge $i", 
							$mstate->[1], $mstate->[0]);
					} else {	
						$lstate = [$mstate->[0], $mstate->[1], "merge $i"];
					}
				}
			}
		}
		

		# Process locally optimal state
		print(("-" x 60) . "\n");
		if ($lstate) {
			# Reset partitions in mergings
			if ($lstate->[2] =~ /^merge!? ([0-9]*)$/) {
				# Merging: reset partitions $i, ... in $opt_cover
				for (my $i = $1; $i < scalar(@{$lstate->[1]}); ++$i) {
					$lstate->[1][$i]->opt_partitioning(undef);
				}
			}

			# Recompute mlogp for $lstate
			$lstate->[0] = $self->mlog_posterior($lstate->[1]);

			# Print performed action
			print $self->print_cover2("Action[$changes]: " .
				$lstate->[2], $lstate->[1], $lstate->[0]);

			# Promote $lstate to $gstate if better
			if ((! $gstate) || $lstate->[0] < $gstate->[0]) {
				$gstate = $lstate;
			}

			# Promote $gstate to $state if better
			if ($gstate->[0] < $state->[0]) {
				print $self->print_cover2("    gstate:", 
					$gstate->[1], $gstate->[0]);
				print $self->print_cover2("    state:", 
					$state->[1], $state->[0]);
	
				# Check that $state is nondegenerate!
				my $degenerate = 0;
				for (my $i = 0; $i < $#{$gstate->[1]}; ++$i) {				
					if ($gstate->[1][$i]->count() < $self->mindata()
						|| $gstate->[1][$i]->count() < $self->total()
							* $gstate->[1][$i]->prior_mass()) {
						$degenerate = 1;
						last();
					}
				}

				# Only promote non-degenerate
				if (! $degenerate) {
					$state = $gstate;
					$self->cover($state->[1]);
					$depth = 0;
					print "    IMPROVEMENT\n";
				} else {
					print "    DEGENERATE\n";
				}
			}
		} else {
			print $self->print_cover2("    Action[$changes]: exit",
					$state->[1], $state->[0]);
		}
		print(("-" x 60) . "\n");
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/learn6.pl
## ------------------------------------------------------------

sub learn6 {
	my $self = shift;
	my $data = shift;
	my $true = shift;
	my $nparams = shift;

	# Calculate true mlogp
	my $true_mlogp = $nparams / 2 * log($data->count());
	foreach my $d (@{$data->data()}) {
		my $o = $data->outcome($d);
		my $fo = &$true($o);
		print DTAG::Interpreter::dumper($o) . " f=$fo\n";
		$true_mlogp -= log(&$true($o));
	}
	$self->var('true_mlogp', $true_mlogp);

	# Create root partition
	my $hierarchy = $self->hierarchy();
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);
	$self->cover([$root]);
	
	# Create cover hash with visited covers
	my $visited = {};

	# Initialize states
	my $state = [$self->mlog_posterior($self->cover()), 
		$self->cover(), 'root'];
	$self->var('mlogp', $state->[0]);
	my $lstate = $state; 
	my $gstate = undef;

	# Initialize depths and changes
	my $depth = 0;
	my $maxdepth = 30;
	my $changes = 0;

	# Improve cover by local search
	while ($depth < $maxdepth && defined($lstate)) {
		# Increment depth and changes
		++$depth;
		++$changes;
		my $skip = 0;
		my $mlogp_old = $lstate->[0];
		my $cover = $lstate->[1];
		$visited->{$self->print_cover($cover)} += 1;

		# Print current cover
		print $self->print_cover2(
			($depth > 1 ? "DEPTH $depth: " : ""),
			$cover, 
			$lstate->[0]);

		# Reset locally optimal cover
		$lstate = undef;

		# Merge partitions with fewer than $mindata observations
		for (my $i = 0; $i < $#$cover; ++$i) {
			if ($cover->[$i]->count() < $self->mindata()
					|| $cover->[$i]->count() < $self->total()
						* $cover->[$i]->prior_mass()) {
				# Compute optimal cover produced by merging and its weight
				my $mstate = $self->merge($cover, $i);

				# Use the merging of $i, unless previously visited
				if ($mstate && $mstate->[1]) {
					if ($visited->{$self->print_cover($mstate->[1])} && 0) {
						print $self->print_cover2("REJECTED merge!", 
							$mstate->[1], $mstate->[0]);
					} else {
						$lstate = [-1e100, $mstate->[1], "merge! $i"];
						$skip = 1;
						--$depth;
						last();
					}
				}
			}
		}
		
		# Proceed with partitions and mergings, unless asked to skip
		if (! $skip) {
			# Find optimal partitionings of each class
			for (my $i = 0; $i <= $#$cover; ++$i) {
				# Debug
				print "    Partitioning $i\n";

				# Find optimal partitioning of the partition
				my $partition = $cover->[$i];
				my $pstate = $partition->opt_partitioning()
					|| $partition->compute_opt_partitioning6($self,
						[@$cover[0..$i-1]], [@$cover[($i+1)..$#$cover]]);

				# Use partitioning if better than $lstate
				if ($pstate && $pstate->[1] && (((! $lstate) 
						|| $pstate->[0] < $lstate->[0]))) {
					if (($visited->{$self->print_cover($pstate->[1])} 
							|| 0) > 1) {
						print $self->print_cover2("REJECTED split $i", 
							$pstate->[1], $pstate->[0]);
					} else {
						$lstate = [$pstate->[0],
							$pstate->[1], "split $i"];
					}
				}
			}
		
			# Find optimal mergings of each class
			if (! $lstate) {
				for (my $i = 0; $i < $#$cover; ++$i) {
					# Compute optimal cover produced by merging and its weight
					my $mstate = $self->merging2($cover, $i);

					# Use merging if better than $lstate
					if ($mstate && $mstate->[1] 
							&& ((! $lstate) || $mstate->[0] < $lstate->[0])) {
						if ($visited->{$self->print_cover($mstate->[1])}) {
							print $self->print_cover2("REJECTED merge $i", 
								$mstate->[1], $mstate->[0]);
						} else {	
							$lstate = [$mstate->[0], $mstate->[1], "merge $i"];
						}
					}
				}
			}
		}
		

		# Process locally optimal state
		print(("-" x 60) . "\n");
		if ($lstate) {
			# Reset partitions in mergings
			if ($lstate->[2] =~ /^merge!? ([0-9]*)$/) {
				# Merging: reset partitions $i, ... in $opt_cover
				for (my $i = $1; $i < scalar(@{$lstate->[1]}); ++$i) {
					$lstate->[1][$i]->opt_partitioning(undef);
				}
			}

			# Recompute mlogp for $lstate
			$lstate->[0] = $self->mlog_posterior($lstate->[1]);

			# Print performed action
			print $self->print_cover2("Action[$changes]: " .
				$lstate->[2], $lstate->[1], $lstate->[0]);

			# Promote $lstate to $gstate if better
			if ((! $gstate) || $lstate->[0] < $gstate->[0]) {
				$gstate = $lstate;
			}

			# Promote $gstate to $state if better
			if ($gstate->[0] < $state->[0]) {
				print $self->print_cover2("    gstate:", 
					$gstate->[1], $gstate->[0]);
				print $self->print_cover2("    state:", 
					$state->[1], $state->[0]);
	
				# Check that $state is nondegenerate!
				my $degenerate = 0;
				for (my $i = 0; $i < $#{$gstate->[1]}; ++$i) {				
					if ($gstate->[1][$i]->count() < $self->mindata()
						|| $gstate->[1][$i]->count() < $self->total()
							* $gstate->[1][$i]->prior_mass()) {
						$degenerate = 1;
						last();
					}
				}

				# Only promote non-degenerate
				if (! $degenerate) {
					$state = $gstate;
					$self->cover($state->[1]);
					$self->var('mlogp', $state->[0]);
					$depth = 0;
					print "    IMPROVEMENT\n";
				} else {
					print "    DEGENERATE\n";
				}
			}
		}
		print(("-" x 60) . "\n");
	}
	print $self->print_cover2("    Action[$changes]: exit",
		$state->[1], $state->[0]);
	print "true_mlogp=" . $self->var('true_mlogp') . "\n";
		print(("-" x 60) . "\n");
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/learn7.pl
## ------------------------------------------------------------

sub learn7 {
	my $self = shift;
	my $data = shift;
	my $true = shift;
	my $nparams = shift;

	# Calculate true mlogp
	my $true_mlogp = $nparams / 2 * log($data->count());
	foreach my $d (@{$data->data()}) {
		my $o = $data->outcome($d);
		my $fo = &$true($o);
		print DTAG::Interpreter::dumper($o) . " f=$fo\n";
		$true_mlogp -= log(&$true($o));
	}
	$self->var('true_mlogp', $true_mlogp);

	# Create root partition
	my $hierarchy = $self->hierarchy();
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);
	$self->cover([$root]);
	
	# Initialize states
	my $state = [$self->mlog_posterior($self->cover()), 
		$self->cover(), 'root'];
	$self->var('mlogp', $state->[0]);

	# Improve cover by local search
	my $changes = 0;
	my $maxchanges = 1000;
	my $nstate;
	my $next = 0;
	my $status = 1; 	# 0=init 1=partioning 2=pfail 4=merging 8=mfail
	do {
		# Increment depth and changes
		++$changes;
		my $cover = $state->[1];

		# Print current cover
		print $self->print_cover2("Action[$changes]: " .
			$state->[2], $state->[1], $state->[0]);

		# Find first possible partitioning
		$nstate = undef;
		for (my $ir = 0; $ir <= $#$cover && ($status & 1); ++$ir) {
			my $i = ($ir + $next) % ($#$cover + 1);
			print "    Partitioning $i\n";

			# Find optimal partitioning of $i
			my $partition = $cover->[$i];

			# Compute optimal partitioning, if necessary
			my $precover = [@$cover[0..$i-1]];
			my $postcover = [@$cover[($i+1)..$#$cover]];
			my $pstate = $partition->opt_partitioning();
			if ($pstate) {
				print $self->print_cover2("      cached",
					[@$precover, @{$pstate->[1]}, @$postcover],
					$pstate->[0]) if ($pstate->[1]);
			} else {
				$pstate = $partition->compute_opt_partitioning7($self,
					$precover, $postcover, $state->[0]);
			}
			next() if (! @$pstate);

			# Is the partition an improvement?
			if ($pstate->[0] < 0 
					&& ((! $nstate) 
						|| $pstate->[0] + $state->[0] < $nstate->[0])) { 
				# Compute reduced state
				my $rstate = $self->reduce([0, [@$precover, @{$pstate->[1]},
					@$postcover]]);
				$rstate->[0] = $self->mlog_posterior($rstate->[1]);

				# Is the reduced partition an improvement?
				if ($rstate->[0] < $state->[0] 
						&& ((! $nstate) || $rstate->[0] < $nstate->[0])) {
					$nstate = [$rstate->[0], $rstate->[1], "split $i"];
					$next = $i;
					$status = 1;
					last();
				} else {
					$partition->{'opt_partitioning'} = undef;
				}
			}
		}

		# Check whether partitioning was successful
		if (($status & 1) && ! $nstate) {
			$status = ($status & 8) ? 0 : 6;
			print "pstatus=$status\n";
			$next = 0;
		}

		# Find first possible merging
		for (my $ir = 0; $ir < $#$cover && ($status & 4); ++$ir) {
			# Attempt merge
			my $i = ($ir + $next) % ($#$cover + 1);
			my $mstate = $self->merge($cover, $i);
			next() if (! $mstate);
			my $rstate = $self->reduce($mstate);

			# Debug
			print $self->print_cover2("      merge $i",
				$rstate->[1], $rstate->[0] - $state->[0]);

			# Reduce merged state
			if ($rstate->[0] < $state->[0]) {
				$nstate = [$rstate->[0], $rstate->[1], "merge $i"];
				$next = $i;
				$status = 4;
				last();
			}
		}

		# Check whether merging was successful
		if (($status & 4) && ! $nstate) {
			print "mstatus=$status\n";
			if ($status & 2) {
				$status = 0;
			} else {
				$status = 1 + 8;
				$next = 0;
			}
		}

		# Set $state to $nstate
		$state = $nstate if ($nstate);

		# Recompute mlogp for $state
		#my $mlogp  = $self->mlog_posterior($state->[1]); 
		#if (abs($mlogp - $state->[0]) / max($mlogp, 1) > 0.001) {
		#	print "WARNING: mlog_posterior error: mlogp=$mlogp smlogp=" 
		#		. $state->[0] . "\n";
		#}
	} until ((! $status) || $changes > $maxchanges);

	# Exit
	$self->var('mlogp', $state->[0]);
	$self->cover($state->[1]);
	print $self->print_cover2("    Action[$changes]: exit",
		$state->[1], $state->[0]) if ($state);
	print "true_mlogp=" . $self->var('true_mlogp') . "\n";
		print(("-" x 60) . "\n");
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/merge.pl
## ------------------------------------------------------------

sub merge {
	my $self = shift;
	my $cover = shift;
	my $child = shift;
	my $precover = shift || [];

	# Find parent of partition $child
	my $partition_box = $cover->[$child]->space_box();
	my $hierarchy = $self->hierarchy();
	my $parent = undef;
	for (my $j = $child+1; $j <= $#$cover; ++$j) {
		my $parent_box = $cover->[$j]->space_box();
		if ($hierarchy->box_contains($parent_box, $partition_box)) {
			$parent = $j;
			last();
		}
	}
	return undef if (! defined($parent));
	
	# Start by creating the new cover.
	my $newcover = [@$cover[0..($child-1)]];
	foreach my $p (@$cover[($child+1)..$parent]) {
		my $clone = $p->clone();
		my $dataclone = $p->data()->clone();
		$clone->data($dataclone);
		$dataclone->observations([@{$dataclone->observations}]);
		push @$newcover, $clone;
	}
	push @$newcover, @$cover[($parent+1)..$#$cover];

	# Add each observation in $cover->[$child] to the appropriate partition
	# in the new cover
	my $data = $cover->[$child]->data();
	foreach my $d (@{$data->observations()}) {
		# Find partition in $newcover containing $d
		my $k = $self->find_partition_index($data->outcome($d), $newcover);

		# Add observation to partition $k, if $child <= $k < $parent
		my $kdata = $newcover->[$k]->data();
		if ($child <= $k && $k < $parent) {
			$kdata->add($kdata->outcome($d));
			$newcover->[$k]->{'subdata'} = undef;
		}
	}

	# Compute prior mass for each partition after $child
	for (my $j = $child; $j < $parent; ++$j) {
		my $p = $newcover->[$j];
		my $prior_mass = $p->compute_prior_mass($self, [@$precover, 
			@$newcover[0..$j-1]]);
		$p->{'opt_partitioning'} = undef;

		# Reject if prior mass is non-positive
		if ($prior_mass <= 0) {
			$p->prior_mass(0);
			print "ERROR: illegal prior mass when merging "
				. " from " . $self->print_cover($cover) . "\n";
			# return [1e100, undef];
		}
	}

	# Compute mlog_posterior
	my $mlog_posterior = $self->mlog_posterior($newcover);

	# Return cover and mlog_posterior
	return [$mlog_posterior, $newcover];
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/merge2.pl
## ------------------------------------------------------------

sub merge2 {
	my $self = shift;
	my $cover = shift;
	my $child = shift;
	my $precover = shift || [];

	# Find parent of partition $child
	my $partition_box = $cover->[$child]->space_box();
	my $hierarchy = $self->hierarchy();
	my $parent = undef;
	for (my $j = $child+1; $j <= $#$cover; ++$j) {
		my $parent_box = $cover->[$j]->space_box();
		if ($hierarchy->box_contains($parent_box, $partition_box)) {
			$parent = $j;
			last();
		}
	}
	return undef if (! defined($parent));
	
	# Start by creating the new cover.
	my $newcover = [@$cover[0..($child-1)]];
	foreach my $p (@$cover[($child+1)..$parent]) {
		my $clone = $p->clone();
		my $dataclone = $p->data()->clone();
		$clone->data($dataclone);
		$dataclone->observations([@{$dataclone->observations}]);
		push @$newcover, $clone;
	}
	push @$newcover, @$cover[($parent+1)..$#$cover];

	# Add each observation in $cover->[$child] to the appropriate partition
	# in the new cover
	my $data = $cover->[$child]->data();
	foreach my $d (@{$data->observations()}) {
		# Find partition in $newcover containing $d
		my $k = $self->find_partition_index($data->outcome($d), $newcover);

		# Add observation to partition $k, if $child <= $k < $parent
		my $kdata = $newcover->[$k]->data();
		if ($child <= $k && $k < $parent) {
			$kdata->add($kdata->outcome($d));
			$newcover->[$k]->{'subdata'} = undef;
		}
	}

	# Compute prior mass for each partition after $child
	for (my $j = $child; $j < $parent; ++$j) {
		my $p = $newcover->[$j];
		my $prior_mass = $p->compute_prior_mass($self, [@$precover, 
			@$newcover[0..$j-1]]);

		# Reject if prior mass is non-positive
		if ($prior_mass <= 0) {
			$p->prior_mass(0);
			print "ERROR: illegal prior mass when merging "
				. " from " . $self->print_cover($cover) . "\n";
			# return [1e100, undef];
		}
	}

	# Compute mlog_posterior
	my $mlog_posterior = 0;
	for (my $j = 0; $j <= $#$newcover; ++$j) {
		# Compute mlog_posterior, if necessary
		my $p = $newcover->[$j];
		if ($child <= $j && $j < $parent) {
			$p->compute_mlog_posterior($self);
			$p->{'opt_partitioning'} = undef;
		}

		# Compute total mlog_posterior
		$mlog_posterior += $p->mlog_posterior();
	}

	# Return cover and mlog_posterior
	return [$mlog_posterior, $newcover];
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/merging.pl
## ------------------------------------------------------------

sub merging {
	my $self = shift;
	my $cover = shift;
	my $i = shift;
	my $old_mlog_posterior = shift || 0;

	# Check that merging is valid, ie, $cover->[$i-1] must be a
	# subspace of $cover->[$i]; if not, return immediately
	my $hierarchy = $self->hierarchy();
	my $partition_box = $cover->[$i]->space_box();
	my $subpartition_box = $cover->[$i-1]->space_box();
	return [1e100, undef]
		if (! $hierarchy->box_contains($partition_box, $subpartition_box));

	# Otherwise, return cover produced by merging partition $i with its parent
	my $newcover = $self->merge($cover, $i);
	
	# Debug
 	if ($newcover) {
		print "    "  
            . sprintf("%10s", 
				sprintf("%8g", $newcover->[0] - $old_mlog_posterior))
			. " merge " . $self->print_cover($newcover->[1]) 
			. " from " . $self->print_cover($cover) . "\n";
	}

	# Return
	return $newcover ? $newcover : [1e100, undef];
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/merging2.pl
## ------------------------------------------------------------

sub merging2 {
	my $self = shift;
	my $cover = shift;
	my $i = shift;
	my $old_mlog_posterior = shift || 0;

	# Return cover produced by merging partition $i with its parent
	my $newcover = $self->merge($cover, $i);
	
	# Debug
 	if ($newcover) {
		print "    "  
            . sprintf("%10s", 
				sprintf("%8g", $newcover->[0] - $old_mlog_posterior))
			. " merge " . $self->print_cover($newcover->[1]) 
			. " from " . $self->print_cover($cover) . "\n";
	}

	# Return
	return $newcover ? $newcover : [1e100, undef];
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/minmax.pl
## ------------------------------------------------------------

sub min {
	my $min = shift;
	map {$min = $_ if ($_ < $min)} @_;
	return $min;
}

sub max {
	my $max = shift;
	map {$max = $_ if ($_ > $max)} @_;
	return $max;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/mlog_likelihood.pl
## ------------------------------------------------------------

sub mlog_likelihood {
	my $self = shift;
	my $partition = shift;

	# Compute minus log likelihood of data in all partitions
	my $mlogL = 0;
	my $data = $partition->data();
	foreach my $d (@{$data->data()}) {
		$mlogL -= log($partition->f($data->outcome($d), $self) || 1e-100);
	}

	# Return minus log likelihood
	return $mlogL;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/mlog_posterior.pl
## ------------------------------------------------------------

sub mlog_posterior {
	my $self = shift;
	my $cover = shift || $self->cover();

	# Compute minus-log probability for each partition in cover
	my $mlog_posterior = 0;
	my $mlog_posterior_function = $self->mlog_posterior_function();
	foreach my $partition (@$cover) {
		# Update minus-log probability in partition 
		$partition->mlog_posterior(
			&$mlog_posterior_function($self, $partition)) 
			if (! defined($partition->mlog_posterior()));

		# Add partition mlog posterior to total mlog posterior
		$mlog_posterior += $partition->mlog_posterior();
	}

	# Return total minus-log posterior probability
	return $mlog_posterior;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/mlog_posterior_function.pl
## ------------------------------------------------------------

sub mlog_posterior_function {
	my $self = shift;
	$self->{'mlog_posterior_function'} = shift() if (@_);
	return $self->{'mlog_posterior_function'} || $mlog_posterior_function;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/new.pl
## ------------------------------------------------------------

# EHPM->new($hierarchy, $prior, $smoothing)

sub new {
	my $proto = shift;
	my $hierarchy = shift;
	my $prior = shift || sub { 1 };
	my $smoothing = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Initialize object
	$self->hierarchy($hierarchy);
	$self->prior($prior);
	$self->smoothing(defined($smoothing) ? $smoothing : 0);
	$self->cover([DTAG::Learner::Partition->new()]);

	# Initialize 
	# Return new object
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/partitioning2cover.pl
## ------------------------------------------------------------

sub partitioning2cover {
	my $self = shift;
	my $i = shift;
	my $partitioning = shift;

	# Extract parameters
	my $delta = $partitioning->[0];
	my $child = $partitioning->[1];
	my $parent = $partitioning->[2];

	# Create new cover
	my $newcover = [@{$self->cover()}];
	splice(@$newcover, $i, 1, $child, $parent);
	
	# Return new cover
	return $newcover;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/partitioning2cover2.pl
## ------------------------------------------------------------

sub partitioning2cover2 {
	my $self = shift;
	my $i = shift;
	my $partitioning = shift;

	# Create new cover
	my $newcover = [@{$self->cover()}];
	splice(@$newcover, $i, 1, @$partitioning[1..$#$partitioning]);
	
	# Return new cover
	return $newcover;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/print.pl
## ------------------------------------------------------------

sub print {
	my $self = shift;
	my $hierarchy = $self->hierarchy();

	# Print EHPM
	my $s = # "EHPM $self hierarchy=$hierarchy\n" . 
		"total=" . $self->total() 
		. " mlogp=" . $self->var('mlogp') 
		. " truemlogp= " . $self->var('true_mlogp') . "\n";

	# Print cover
	my $i = 0;
	foreach my $p (@{$self->cover()}) {
		$s .= "cover[$i]:"
			. " spacebox=" .  $hierarchy->print_box($p->space_box()) 
			. " count=" . $p->count() 
			. " w=" . ($p->count() / $self->total() / ($p->prior_mass() || 1))
			. " pmass=" . sprintf("%.6g", $p->prior_mass())
			. " mlogP=" . sprintf("%.6g", $p->mlog_posterior()) 
			.  "\n";
		++$i;
	}

	# Return string
	return $s;
}	

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/print_cover.pl
## ------------------------------------------------------------

sub print_cover {
	my $self = shift;
	my $cover = shift;

	my @pboxes = ();
	foreach my $p (@$cover) {
		my $pbox = $p->var('printbox')
			|| $p->var('printbox',
				$self->hierarchy()->print_box($p->space_box()));
		push @pboxes, $pbox;
	}

	return "[" . join(",", @pboxes) . "]";
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/print_cover2.pl
## ------------------------------------------------------------

sub print_cover2 {
	my $self = shift;
	my $info = shift || "";
	my $cover = shift;
	my $mlogp = shift;
	my $rmlogp = shift;

	# Round off
	return ($info ? "$info " : "") 
		. ($mlogp < $self->var('true_mlogp') ? '+' : '-') 
		. "mlogp=" . sprintf("%4g", $mlogp) 
		. (defined($rmlogp) ? " rmlogp=" . sprintf("%4g", $rmlogp) : "")
		. " cover=" . $self->print_cover($cover)
		. " counts=[" . 
				join(",", map {scalar(@{$_->data()->data()})} @$cover)
			. "]" 
		. "\n";
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/prior.pl
## ------------------------------------------------------------

sub prior {
	my $self = shift;
	$self->{'prior'} = shift if (@_);
	return $self->{'prior'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/ps_boxes.pl
## ------------------------------------------------------------

sub ps_boxes {
	my $self = shift;

	# Print boxes 
	my $s = "% Print box outlines\n";
	my $cover = $self->cover();
	for (my $i = $#$cover; $i >= 0; --$i) {
		my $box = $cover->[$i]->space_box();
		$s .= ($box->[0][0] * 100) . " "
			. ($box->[1][0] * 100) . " "
			. ($box->[0][1] * 100) . " "
			. ($box->[1][1] * 100) 
			. " box stroke\n";
	}

	# Return string
	return $s . "\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/ps_boxes_colour.pl
## ------------------------------------------------------------

sub ps_boxes_colour {
	my $self = shift;

	# Print boxes 
	my $s = "% Print box fills\n";
	my $cover = $self->cover();
	my $n = scalar(@$cover) + 1;
	my $k = max(2, int(log($n) / log(3)));

	# Print boxes
	for (my $i = ($#$cover - 1); $i >= 0; --$i) {
		my $red = (($i + 1) % $k) / $k;
		my $blue = (int(($i + 1) / $k) % $k) / $k;
		my $green = (int(($i + 1) / $k / $k) % $k) / $k;

		my $box = $cover->[$i]->space_box();
		$s .= "$red $green $blue setrgbcolor "
			. ($box->[0][0] * 100) . " "
			. ($box->[1][0] * 100) . " "
			. ($box->[0][1] * 100) . " "
			. ($box->[1][1] * 100) 
			. " box fill\n";
	}

	# Return string
	return $s . "0 setgray\n\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/ps_data.pl
## ------------------------------------------------------------

sub ps_data {
	my $self = shift;

	# Plot PSMath data
	my $s = "% Plot data\n";
	foreach my $p (@{$self->cover()}) {
		my $data = $p->data();
		foreach my $d (@{$data->data()}) {
			my $point = $data->outcome($d);
			$s .= ($point->[0] * 100) . " " 
				. ($point->[1] * 100) . " dot\n";
		}
	}

	# Return string
	return $s . "\n0 0 100 100 box stroke\n\n";
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/ps_dist.pl
## ------------------------------------------------------------

sub ps_dist {
	my $self = shift;
	my $f = shift || sub {$self->f(@_)};

	# Parameters
	my $n = 100;
	my $exp = 2;
	my $mingray = 0.2;
	my $maxdist = log(100) / log(2);

	# Find maximum value of distribution
	my $max = 0;
	for (my $i = 0.5; $i < $n; ++$i) {
		for (my $j = 0.5; $j < $n; ++$j) {
			my $value = &$f([$i / $n, $j / $n]) || 0;
			$max = $value if ($value > $max);
		}
	}

	# Print values
	my $s = "% Print distribution\ngsave\n";
	for (my $i = 0.5; $i < $n; ++$i) {
		for (my $j = 0.5; $j < $n; ++$j) {
			my $value = &$f([$i / $n, $j / $n]) || 1e-100;
			# my $dist = - log($value / $max) / log($exp);
			# my $epsilon = min($maxdist, $dist) / $maxdist;
			# my $gray = sprintf("%.2g", $epsilon + (1-$epsilon) * $mingray);
			my $gray = sprintf("%.2g", 1 - ($value / $max) * (1 - $mingray));

			# Print box
			$s .= 
				"$gray setgray "
				. (($i - 0.5) / $n * 100) . " " . (($j - 0.5) / $n * 100) . " " 
				. (($i+0.5) / $n * 100) . " " . (($j + 0.5) / $n * 100) . " box gsave stroke grestore fill\n";
		}
	}

	
	# Return string
	return $s . "grestore\n0 setgray 0 0 100 100 box stroke\n\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/reduce.pl
## ------------------------------------------------------------

sub reduce {
	my $self = shift;
	my $split = shift;
	my $precover = shift || [];

	# Reduce cover
	my $rsplit = $split;
	for (my $i = 0; $i < $#{$rsplit->[1]}; ++$i) {
		# Fix partition $i in $rsplit if degenerate
		my $p = $rsplit->[1][$i];
		if ($p->count() < $self->mindata()
				# || $p->count() < $p->mlog_posterior() * $self->total()
			) {
			my $merged = $self->merge($rsplit->[1], $i, $precover);
			if ($merged && $merged->[1]) {
				$rsplit = $merged;
				--$i;
			}
		}
	}

	# Return
	return $rsplit;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/save_file.pl
## ------------------------------------------------------------

sub save_file {
	my $self = shift;
	my $file = shift;
	my $data = shift;

	# Save data in file
	open(FILE, ">$file");
	print FILE $data;
	close(FILE);
}
	

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/save_ps.pl
## ------------------------------------------------------------

sub save_ps {
	my $self = shift;
	my $file = shift;

	# Save data in file
	open(FILE, ">$file");

	# Find bounding box
	my $bbox = "";
	foreach my $s (@_) {
		$bbox = $s if ($s =~ /^\%\%BoundingBox:/);
	}

	# Open PSMath
	print FILE '%!PS-Adobe-2.0 EPSF-1.2' . "\n$bbox\n";
	print FILE <<'eof_data';

% Procedures for drawing boxes and dots
/box {
	3 index 3 index moveto
	3 index 1 index lineto
	1 index 1 index lineto
	1 index 3 index lineto closepath
	pop pop pop pop
} def
	
/dot {
	newpath 0.5 0 360 arc fill
} def

eof_data

	# Print contents
	print FILE join("\n",@_);

	# Close PSMath
	print FILE <<'eof_data';
% Print rectangle
0 0 100 100 box stroke

%%EOF
eof_data

	# Close file
	close(FILE);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/smoothing.pl
## ------------------------------------------------------------

sub smoothing {
	my $self = shift;
	$self->{'smoothing'} = shift if (@_);
	return $self->{'smoothing'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/subpartition.pl
## ------------------------------------------------------------

sub subpartition {
	my $self = shift;
	my $subpartition = shift;
	my $partition = shift;
	my $subspace = $subpartition->space();
	my $space = $partition->space();

	# Check that $space is an initial subsequence of $subspace
	for (my $i = 0; $i < scalar(@$space); ++$i) {
		return 0 if ($space->[$i] ne $subspace->[$i]);
	}

	# Return 1 if successful
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/total.pl
## ------------------------------------------------------------

sub total {
	my $self = shift;
	$self->{'total'} = shift if (@_);
	return $self->{'total'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/xreplace.pl
## ------------------------------------------------------------

sub xreplace {
	my $self = shift;
	my $changes = shift;
	my $replace = $changes->{$self};

	return $replace->xreplace($changes) || $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/xsplit.pl
## ------------------------------------------------------------

sub xsplit {
	my $self = shift;
	my $parent = shift;
	my $data = shift;
	my $changes = shift;
}
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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::Partition
	
=cut

# --------------------------------------------------

package DTAG::Learner::Partition;
use strict;



## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/children.pl
## ------------------------------------------------------------

sub children {
	my $self = shift;
	return $self->var('children', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/clone.pl
## ------------------------------------------------------------

sub clone {
	my $self = shift;
	
	# Clone this partition
	my $clone = $self->new();
	$clone->count($self->count());
	$clone->data($self->data());
	$clone->plane($self->plane());
	$clone->space($self->space());
	$clone->space_box($self->space_box());
	$clone->plane_box($self->plane_box());

	# Return clone
	return $clone;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_mlog_posterior.pl
## ------------------------------------------------------------

sub compute_mlog_posterior {
	my $self = shift;
	my $distribution = shift;

	# Compute minus-log posterior of partition
	my $mlog_posterior_function = $distribution->mlog_posterior_function();
	return $self->mlog_posterior(
		&$mlog_posterior_function($distribution, $self));
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_opt_partitioning.pl
## ------------------------------------------------------------

sub compute_opt_partitioning {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];

	# Find all partitionings of data
	my $subdata = $distribution->hierarchy()->subdata2(
		$self->space(), $self->data(), $distribution->mindata());
	
	# Initial optimal partitioning is to do nothing at all
	my $opt_partitioning = [0, undef, undef];

	# Process subdata to find better partitionings
	foreach my $d (@$subdata) {
		# Setup child
		my $child = $self->clone();
		$child->setup($distribution, $d, $d->plane(), $self);

		# Find all observations in $self that are not in child
		my $hash = {};
		my $list = [];
		map {$hash->{$_} = 1} @{$child->data()->observations()};
		map {push @$list, $_ if (! $hash->{$_})}
			@{$self->data()->observations()};
		
		# Setup parent
		my $pdata = $self->data()->clone();
		$pdata->observations($list);
		my $parent = $self->clone();
		$parent->init($distribution, $pdata, $self->plane(), $self->space());

		# Compute prior probability mass of child and parent
		$child->compute_prior_mass($distribution, $precover);
		$parent->compute_prior_mass($distribution, [@$precover, $child]);

		# Compute posterior probability of child and parent
		my $delta = $child->compute_mlog_posterior($distribution)
			+ $parent->compute_mlog_posterior($distribution) 
			- $self->mlog_posterior();

		# Debug
		print "    delta=" .
			sprintf("%.4g", $delta)
			. " splitting " 
			. $distribution->hierarchy()->print_box($self->space_box()) 
			. " with " 
			. $distribution->hierarchy()->print_plane($d->plane())
			. "\n";

		# If $delta is smaller than $opt_delta, then new partitioning
		# is currently optimal
		if ($delta < $opt_partitioning->[0]) {
			$opt_partitioning = [$delta, $child, $parent];
		}
	}

	# Set optimal delta and partitioning
	$self->opt_partitioning($opt_partitioning);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_opt_partitioning2.pl
## ------------------------------------------------------------

sub compute_opt_partitioning2 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self]];
	my $optsplit = $split;
	my $loptsplit = $split; 
	my $maxdepth = 20;
	my $depth = 0;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth && $optsplit->[0] >= 0) {
		# Increment depth
		++$depth;
		print "    DEPTH $depth at " 
			. $distribution->print_cover([@$precover, @{$split->[1]},
				@$postcover])
			. "\n" if ($depth > 1);

		# Reset best split at current depth
		$loptsplit = undef;
		my $super = $split->[1][0];

		# Find all partitions of data
		my $subdata = $distribution->hierarchy()->subdata2(
			$super->space(), $super->data(), $distribution->mindata());
	
		# Try all partitions of data to find the locally best
		foreach my $d (@$subdata) {
			# Setup child
			my $child = $super->clone();
			$child->setup($distribution, $d, $d->plane(), $super);

			# Find all observations in $super that are not in child
			my $hash = {};
			my $list = [];
			map {$hash->{$_} = 1} @{$child->data()->observations()};
			map {push @$list, $_ if (! $hash->{$_})}
				@{$super->data()->observations()};
			
			# Setup parent
			my $pdata = $super->data()->clone();
			$pdata->observations($list);
			my $parent = $super->clone();
			$parent->init($distribution, $pdata, $super->plane(), 
				$super->space());

			# Compute prior probability mass of child and parent
			$child->compute_prior_mass($distribution, $precover);
			$parent->compute_prior_mass($distribution, [@$precover, $child]);

			# Compute posterior probability of child and parent
			my $delta = $child->compute_mlog_posterior($distribution)
				+ $parent->compute_mlog_posterior($distribution) 
				- $super->mlog_posterior() + $split->[0];

			# Debug
			my $cover = $split->[1];
			print "    " 
            	. sprintf("%10s", sprintf("% 8g", $delta))
				. " split " 
				. $distribution->print_cover([@$precover, $child, $parent, 
					@$cover[1..$#$cover], @$postcover])
				. "\n";

			# If $delta is smaller than $opt_delta, then new partitioning
			# is currently optimal
			if ((! defined($loptsplit)) || $delta < $loptsplit->[0]) {
				$loptsplit = [$delta, [$child, $parent, 
					@$cover[1..$#$cover]]];
			}
		}

		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && $loptsplit->[0] < $optsplit->[0]) {
			$optsplit = $loptsplit;
		}
	}

	# Set optimal delta and partitioning
	if ($optsplit->[0] < 0) {
		return [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover]];
	} else {
		return undef;
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_opt_partitioning3.pl
## ------------------------------------------------------------

sub compute_opt_partitioning3 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self], 0];
	my $optsplit = $split;
	my $loptsplit = $split; 
	my $maxdepth = 20;
	my $depth = 0;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth && $optsplit->[0] >= 0) {
		# Increment depth
		++$depth;
		print "    DEPTH $depth at " 
			. $distribution->print_cover([@$precover, @{$split->[1]},
				@$postcover])
			. "\n" if ($depth > 1);

		# Reset best split at current depth
		$loptsplit = undef;
		my $super = $split->[1][0];

		# Find all partitions of data
		my $subdata = $distribution->hierarchy()->subdata2(
			$super->space(), $super->data(), $distribution->mindata());
	
		# Try all partitions of data to find the locally best
		foreach my $d (@$subdata) {
			# Setup child
			my $child = $super->clone();
			$child->setup($distribution, $d, $d->plane(), $super);

			# Find all observations in $super that are not in child
			my $hash = {};
			my $list = [];
			map {$hash->{$_} = 1} @{$child->data()->observations()};
			map {push @$list, $_ if (! $hash->{$_})}
				@{$super->data()->observations()};
			
			# Setup parent
			my $pdata = $super->data()->clone();
			$pdata->observations($list);
			my $parent = $super->clone();
			$parent->init($distribution, $pdata, $super->plane(), 
				$super->space());

			# Compute prior probability mass of child and parent
			$child->compute_prior_mass($distribution, $precover);
			$parent->compute_prior_mass($distribution, [@$precover, $child]);

			# Compute posterior probability of child and parent
			my $delta = $child->compute_mlog_posterior($distribution)
				+ $parent->compute_mlog_posterior($distribution) 
				- $super->mlog_posterior() + $split->[0];

			# Compute moved count
			my $moved_count = $child->count() 
				- $child->prior_mass() * $distribution->total();

			# Debug
			my $cover = $split->[1];
			print "    " 
            	. sprintf("%8s", sprintf("% 6g", $delta))
            	. sprintf("%8s", sprintf("% 6g", $moved_count))
				. " split " 
				. $distribution->print_cover([@$precover, $child, $parent, 
					@$cover[1..$#$cover], @$postcover])
				. "\n";

			# If $delta is smaller than $opt_delta, then new partitioning
			# is currently optimal
			if ((! defined($loptsplit)) || $delta < 0
				&& $loptsplit->[2] < $moved_count) {
				$loptsplit = [$delta, [$child, $parent, 
					@$cover[1..$#$cover]], $moved_count];
			}
		}

		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && $loptsplit->[0] < 0 
				&& $loptsplit->[2] > $optsplit->[2]) {
			$optsplit = $loptsplit;
		}
	}

	# Set optimal delta and partitioning
	if ($optsplit->[0] < 0) {
		return [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover],
			$optsplit->[2]];
	} else {
		return undef;
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_opt_partitioning4.pl
## ------------------------------------------------------------

sub compute_opt_partitioning4 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self], 0];
	my $optsplit = $split;
	my $loptsplit = $split; 
	my $maxdepth = 20;
	my $depth = 0;
	my $newcover;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth && $optsplit->[0] >= 0) {
		# Increment depth
		++$depth;
		print "    DEPTH $depth at " 
			. $distribution->print_cover([@$precover, @{$split->[1]},
				@$postcover])
			. "\n" if ($depth > 1);

		# Reset best split at current depth
		$loptsplit = undef;
		my $super = $split->[1][0];

		# Find all partitions of data
		my $subdata = $distribution->hierarchy()->subdata2(
			$super->space(), $super->data(), $distribution->mindata());
	
		# Try all partitions of data to find the locally best
		foreach my $d (@$subdata) {
			# Setup child
			my $child = $super->clone();
			$child->setup($distribution, $d, $d->plane(), $super);

			# Find all observations in $super that are not in child
			my $hash = {};
			my $list = [];
			map {$hash->{$_} = 1} @{$child->data()->observations()};
			map {push @$list, $_ if (! $hash->{$_})}
				@{$super->data()->observations()};
			
			# Setup parent
			my $pdata = $super->data()->clone();
			$pdata->observations($list);
			my $parent = $super->clone();
			$parent->init($distribution, $pdata, $super->plane(), 
				$super->space());

			# Compute prior probability mass of child and parent
			$child->compute_prior_mass($distribution, $precover);
			$parent->compute_prior_mass($distribution, [@$precover, $child]);

			# Compute posterior probability of child and parent
			my $delta = $child->compute_mlog_posterior($distribution)
				+ $parent->compute_mlog_posterior($distribution) 
				- $super->mlog_posterior() + $split->[0];

			# Compute moved count
			my $moved_count = $child->count() 
				- $child->prior_mass() * $distribution->total();

			# Compute new cover
			my $cover = $split->[1];
			$newcover = [$child, $parent, @$cover[1..$#$cover]];

			# Delete parent if it is degenerate
			print "        parent=" . $parent->count() . " moved=" .
				($parent->count() - $parent->prior_mass() *
					$distribution->total())	. "\n";
			if ($parent->count() < $distribution->mindata() ||
				$parent->count() - $parent->prior_mass() *
					$distribution->total()) {
				my $merged = $distribution->merge($newcover, 1);
				if ($merged && $merged->[1]) {
					$delta = $merged->[0] - $super->mlog_posterior();
					$newcover = $merged->[1];
				}
			} 

			# Debug
			print "    " 
            	. sprintf("%8s", sprintf("% 6g", $delta))
            	. sprintf("%8s", sprintf("% 6g", $moved_count))
				. " split " 
				. $distribution->print_cover([@$precover, @$newcover,
					@$postcover])
				. "\n";

			# If $delta is smaller than $opt_delta, then new partitioning
			# is currently optimal
			if ((! defined($loptsplit)) || ($moved_count >= 0 
				&& $delta < $loptsplit->[0])) {
				$loptsplit = [$delta, $newcover, $moved_count];
			}
		}

		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && $loptsplit->[2] >= 0 
				&& ((! defined($optsplit)) 
					|| $loptsplit->[0] < $optsplit->[0])) {
			$optsplit = $loptsplit;
		}
	}

	# Set optimal delta and partitioning
	if ($optsplit->[0] <= 0) {
		return [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover],
			$optsplit->[2]];
	} else {
		return [1e100, [@$precover, $self, @$postcover], 0];
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_opt_partitioning5.pl
## ------------------------------------------------------------

# split = [$mlog_post, $cover, $info, $moved]

sub compute_opt_partitioning5 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];
	my $mlogp_old = shift || 0;

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self], 0];
	my $loptsplit = $split; 
	my $optsplit = undef;
	my $maxdepth = 10;
	my $depth = 0;
	my $newcover;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth 
			&& ((! $optsplit) || $optsplit->[0] >= 0)) {
		# Increment depth
		++$depth;
		print $distribution->print_cover2("      PDEPTH $depth",
			[@$precover, @{$split->[1]}, @$postcover],
			$mlogp_old + $loptsplit->[0]) if ($depth > 1);

		# Reset best split at current depth
		$loptsplit = undef;
		my $super = $split->[1][0];

		# Find all partitions of data
		my $subdata = $distribution->hierarchy()->subdata2(
			$super->space(), $super->data(), $distribution->mindata());
	
		# Try all partitions of data to find the locally best
		foreach my $d (@$subdata) {
			# Setup child
			my $child = $super->clone();
			$child->setup($distribution, $d, $d->plane(), $super);

			# Find all observations in $super that are not in child
			my $hash = {};
			my $list = [];
			map {$hash->{$_} = 1} @{$child->data()->observations()};
			map {push @$list, $_ if (! $hash->{$_})}
				@{$super->data()->observations()};
			
			# Setup parent
			my $pdata = $super->data()->clone();
			$pdata->observations($list);
			my $parent = $super->clone();
			$parent->init($distribution, $pdata, $super->plane(), 
				$super->space());

			# Compute prior probability mass of child and parent
			$child->compute_prior_mass($distribution, $precover);
			$parent->compute_prior_mass($distribution, [@$precover, $child]);

			# Compute posterior probability of child and parent
			my $delta = $child->compute_mlog_posterior($distribution)
				+ $parent->compute_mlog_posterior($distribution) 
				- $super->mlog_posterior() + $split->[0];

			# Compute moved count
			my $moved_count = $child->count() 
				- $child->prior_mass() * $distribution->total();

			# Compute new cover
			my $cover = $split->[1];
			$newcover = [$child, $parent, @$cover[1..$#$cover]];

			# Delete parent if it is degenerate
			#print "        parent=" . $parent->count() . " moved=" .
			#	($parent->count() - $parent->prior_mass() *
			#		$distribution->total())	. "\n";
			if ($parent->count() < $distribution->mindata() ||
				$parent->count() - $parent->prior_mass() *
					$distribution->total()) {
				my $merged = $distribution->merge($newcover, 1);
				if ($merged && $merged->[1]) {
					$delta = $merged->[0] - $super->mlog_posterior();
					$newcover = $merged->[1];
				}
			} 

			# Debug
			print $distribution->print_cover2("      split",
				[@$precover, @$newcover, @$postcover],
				$delta + $mlogp_old, $moved_count);

			# If $delta is smaller than $opt_delta, then new partitioning
			# is currently optimal
			if ((! $loptsplit) || (! $loptsplit->[1])
				|| ($moved_count >= 0 && $loptsplit->[2] < 0)
				|| ($delta < $loptsplit->[0] 
					&& ! ($moved_count < 0 && $loptsplit->[2] > 0))) {
				$loptsplit = [$delta, $newcover, $moved_count];
			}
		}

		# Debug
		#print "optsplit=" . DTAG::Interpreter::dumper($optsplit) . "\n";
		#print "loptsplit=" . DTAG::Interpreter::dumper($loptsplit) . "\n";
	
		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && ((! $optsplit) 
			|| ($loptsplit->[2] >= 0 && $optsplit->[2] < 0)
			|| ($loptsplit->[0] < $optsplit->[0]
				&& ! ($loptsplit->[2] < 0 && $optsplit->[2] > 0)))) {
			$optsplit = $loptsplit;
		}
	}

	# Return optimal partitioning
	return $optsplit 
		? [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover],
			$optsplit->[2]]
		: undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_opt_partitioning6.pl
## ------------------------------------------------------------

# split = [$mlog_post, $cover, $info, $moved]

sub compute_opt_partitioning6 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];
	my $mlogp_old = shift || 0;

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self], 0];
	my $loptsplit = $split; 
	my $optsplit = undef;
	my $maxdepth = 100;
	my $depth = 0;
	my $newcover;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth 
			&& ((! $optsplit) || $optsplit->[0] >= 0)) {
		# Increment depth
		++$depth;
		#print $distribution->print_cover2("      PDEPTH $depth",
		#	[@$precover, @{$split->[1]}, @$postcover],
		#	$mlogp_old + $loptsplit->[0]) if ($depth > 1);

		# Reset best split at current depth
		$loptsplit = undef;

		# Find all partitionings of partitions in cover, and select
		# partitioning with maximal count
		my $cover = $split->[1];
		my $maxsplit = undef;
		for (my $i = 0; $i <= $#$cover; ++$i) {
			my $partition = $cover->[$i];
			my $subdata = $partition->var('subdata') ||
				$partition->var('subdata', 
					$distribution->hierarchy()->subdata2(
						$partition->space(), $partition->data(), 
						$distribution->mindata()));
			my $count = @$subdata ? $subdata->[0]->count() : 0;
			if ($count && ((! defined($maxsplit)) || $count > $maxsplit->[0])) {
				$maxsplit = [$count, $i];
			}
		}

		# Exit if no partitionings found
		last() if (! $maxsplit);

		# Now create new cover...
		my $super = $cover->[$maxsplit->[1]];
		my $d = $super->var('subdata')->[0];

		# ... setup child
		my $child = $super->clone();
		$child->setup($distribution, $d, $d->plane(), $super);

		# ... find all observations in $super that are not in child
		my $hash = {};
		my $list = [];
		map {$hash->{$_} = 1} @{$child->data()->observations()};
		map {push @$list, $_ if (! $hash->{$_})}
			@{$super->data()->observations()};
			
		# ... setup parent
		my $pdata = $super->data()->clone();
		$pdata->observations($list);
		my $parent = $super->clone();
		$parent->init($distribution, $pdata, $super->plane(), 
			$super->space());

		# ... compute prior probability mass of child and parent
		$child->compute_prior_mass($distribution, $precover);
		$parent->compute_prior_mass($distribution, [@$precover, $child]);

		# Compute new cover
		my $i = $maxsplit->[1];
		$newcover = [@$cover[0..($i-1)], $child, $parent, 
			@$cover[($i+1)..$#$cover]];

		# ... compute posterior probability of child and parent
		$child->compute_mlog_posterior($distribution);
		$parent->compute_mlog_posterior($distribution);

		# Delete parent if it is degenerate
		if ($parent != $self && ($parent->count() < $distribution->mindata())) {
			my $merged = $distribution->merge($newcover, $i+1, $precover);
			if ($merged && $merged->[1]) {
				$loptsplit = $merged;
			}
		} 
		my $mlogp = $distribution->mlog_posterior([@$precover,
			@$newcover, @$postcover]);
		$loptsplit = [$mlogp, $newcover];

		# Debug
		print $distribution->print_cover2("      split",
			[@$precover, @{$loptsplit->[1]}, @$postcover], $mlogp);


		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && ((! $optsplit) 
				|| ($loptsplit->[0] < $optsplit->[0]))) {
			$optsplit = $loptsplit;
		}
	}

	# Delete all degenerate nodes
	if ($optsplit && 0) {
		$newcover = [@$precover, @{$optsplit->[1]}, @$postcover];
		print $distribution->print_cover2("***", $newcover, 0) . "\n"; 
		my $maxi = scalar(@$precover) + scalar(@{$optsplit->[1]});
		for (my $i = scalar(@$precover); $i < $maxi; ++$i) {
			my $p = $newcover->[$i]; 
			if ($p->count() < $distribution->mindata()
				|| $p->count() < $distribution->total() *
					$p->prior_mass()) {
				my $merged = $distribution->merge($newcover, $i);
				if ($merged && $merged->[1]) {
					$newcover = $merged->[1];
					--$maxi; 
					--$i;
				}
			}
		}
		my $mlogp = $distribution->mlog_posterior($newcover);
		$optsplit = [$mlogp, $newcover];
	} 


	# Return optimal partitioning
	return $optsplit 
		? [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover],
			$optsplit->[2]]
		: undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_opt_partitioning7.pl
## ------------------------------------------------------------

# split = [$mlog_post, $cover, $info, $moved]

sub compute_opt_partitioning7 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];
	my $mlogp_old = shift;

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self]];
	my $optsplit = [0];
	my $maxdepth = $distribution->var('maxdepth') || 20;
	my $depth = 0;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth && $optsplit->[0] >= 0) {
		# Increment depth
		++$depth;

		# Save current cover
		my ($mlogp, $cover)  = @$split;

		# Reset current split
		$split = undef;

		# Find all partitionings of partitions in cover, and select
		# partitioning with maximal count
		my $maxcount = undef;
		for (my $i = 0; $i <= $#$cover; ++$i) {
			my $partition = $cover->[$i];
			my $subdata = $partition->var('subdata') ||
				$partition->var('subdata', 
					$distribution->hierarchy()->subdata2(
						$partition->space(), $partition->data(), 
						$distribution->mindata()));
			my $count = @$subdata ? $subdata->[0]->count() : 0;
			if ($count && ((! $maxcount) || $count > $maxcount->[0])) {
				$maxcount = [$count, $i];
			}
		}

		# Stop search if no partitionings found
		if (! $maxcount) {
			print "     stop\n";
		 	last();
		}

		# Find partition to split and associated splitting data
		my $isplit = $maxcount->[1];
		my $super = $cover->[$isplit];
		my $d = $super->var('subdata')->[0];

		# Setup child
		my $child = $super->clone();
		$child->setup($distribution, $d, $d->plane(), $super);

		# Find all observations in $super that are not in child
		my $hash = {};
		my $list = [];
		map {$hash->{$_} = 1} @{$child->data()->observations()};
		map {push @$list, $_ if (! $hash->{$_})}
			@{$super->data()->observations()};
			
		# Setup parent
		my $parent = $super->clone();
		my $pdata = $super->data()->clone();
		$pdata->observations($list);
		$parent->init($distribution, $pdata, $super->plane(), 
			$super->space());

		# Compute prior probability mass of child and parent
		$child->compute_prior_mass($distribution, $precover);
		$parent->compute_prior_mass($distribution, [@$precover, $child]);

		# Compute new cover
		my $newcover = [@$cover[0..($isplit-1)], $child, $parent, 
			@$cover[($isplit+1)..$#$cover]];

		# Compute posterior probability of child and parent
		$child->compute_mlog_posterior($distribution);
		$parent->compute_mlog_posterior($distribution);

		# Compute new mlogp
		my $mlogp_new  = $distribution->mlog_posterior([@$precover,
			@$newcover, @$postcover]);

		# Compute new split
		$split = [$mlogp_new - $mlogp_old, $newcover];

		# Compute reduced non-degenerate split 
		my $rsplit = $distribution->reduce([$mlogp_new, 
			[@$precover, @{$split->[1]}, @$postcover]]);
		$rsplit->[0] = $distribution->mlog_posterior($rsplit->[1])
			- $mlogp_old;

		# Use $rsplit as $optslit if better than current $optsplit
		if ($rsplit->[0] < $optsplit->[0]) {
			$optsplit = $rsplit;
		}

		# Debug
		print $distribution->print_cover2("      split ",
			[@$precover, @{$split->[1]}, @$postcover], $split->[0]);
		print $distribution->print_cover2("      rsplit",
			$rsplit->[1], $rsplit->[0]);
	}

	# Return optimal partitioning
	print $distribution->print_cover2("      esplit",
		[@$precover, @{$split->[1]}, @$postcover], 
		$optsplit->[0]) if ($optsplit->[1]);

	return $self->opt_partitioning($optsplit->[1] 
		? [$optsplit->[0], $split->[1]] : []);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/compute_prior_mass.pl
## ------------------------------------------------------------

sub compute_prior_mass {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift;

	# Compute prior mass
	$self->prior_mass($distribution->hierarchy()->pbox_diff(
		$distribution->prior(), $self->space_box(), 
		map {$_->space_box()} @$precover));

	# Return prior mass
	return $self->prior_mass();
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/count.pl
## ------------------------------------------------------------

sub count {
	my $self = shift;
	$self->{'count'} = shift if (@_);
	my $data = $self->data();
	return $data ? $data->count() : $self->{'count'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/data.pl
## ------------------------------------------------------------

sub data {
	my $self = shift;
	if (@_) {
		my $data = $self->{'data'} = shift;
		$self->count($data->count());
	}
	return $self->{'data'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/f.pl
## ------------------------------------------------------------

sub f {
	my $self = shift;
	my $x = shift;
	my $distribution = shift;

	# Find prior value of $x
	my $priorf = &{$distribution->prior()}($x);
	my $total = $distribution->total();
	my $smoothing = $distribution->smoothing();

	# Compute smoothed value
	my $prior_mass = $self->prior_mass();
	if ($prior_mass <= 0) {
		print ("-" x 80);
		print "\nERROR: prior mass $prior_mass non-positive in partition";
		print $distribution->hierarchy()->print_box($self->space_box());
		print "in EHPM ";
		print $distribution->print();
		print "\n" . ("-" x 80) .  "\n";
	}
	print "ERROR: total $total non-positive\n" if ($total <= 0);

	my $hpm = ($self->count() / ($total || 1)) 
		* ($priorf / ($self->prior_mass() || 1));
	my $epsilon = $smoothing / ($total + $smoothing);
	my $ehpm = (1 - $epsilon) * $hpm + $epsilon * $priorf;
	
	# Return smoothed value
	return $ehpm;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/init.pl
## ------------------------------------------------------------

sub init {
	my $self = shift;
	my $distribution = shift;
	my $data = shift;
	my $plane = shift || $self->plane();
	my $space = shift || $self->space();

	# Compile parameters and store them
	my $hierarchy = $distribution->hierarchy();
	$self->data($data);
	$self->plane($plane);
	$self->space($space);
	$self->plane_box($hierarchy->space2box($plane));
	$self->space_box($hierarchy->space2box($space));
	$self->{'opt_partitioning'} = undef;

	# Return partition
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/mlog_likelihood.pl
## ------------------------------------------------------------

sub mlog_likelihood {
	my $self = shift;
	my $cover = shift || $self->cover();

	# Compute minus-log likelihood of all partitions in cover
	my $mlogL = 0;
	foreach my $partition (@$cover) {
		# Compute minus-log probability of each observation
		my $data = $partition->data();
		foreach my $d (@{$data->data()}) {
			$mlogL += - log($partition->f($data, $self));
		}
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/mlog_posterior.pl
## ------------------------------------------------------------

sub mlog_posterior {
	my $self = shift;
	$self->{'mlog_posterior'} = shift if (@_);
	return $self->{'mlog_posterior'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/new.pl
## ------------------------------------------------------------

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Initialize
	$self->plane([]);
	$self->space([]);

	# Return new object
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/opt_partitioning.pl
## ------------------------------------------------------------

sub opt_partitioning {
	my $self = shift;
	$self->{'opt_partitioning'} = shift if (@_);
	return $self->{'opt_partitioning'};
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/parent.pl
## ------------------------------------------------------------

sub parent {
	my $self = shift;
	return $self->var('parent', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/plane.pl
## ------------------------------------------------------------

sub plane {
	my $self = shift;
	$self->{'plane'} = shift if (@_);
	return $self->{'plane'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/plane_box.pl
## ------------------------------------------------------------

sub plane_box {
	my $self = shift;
	$self->{'plane_box'} = shift if (@_);
	return $self->{'plane_box'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/prior_mass.pl
## ------------------------------------------------------------

sub prior_mass {
	my $self = shift;
	$self->{'prior_mass'} = shift if (@_);
	return $self->{'prior_mass'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/setup.pl
## ------------------------------------------------------------

sub setup {
	my $self = shift;
	my $distribution = shift;
	my $data = shift;
	my $plane = shift;
	my $parent = shift;

	# Compile parameters and store them
	my $space = defined($parent) ? [@{$parent->space()}, @$plane] : $plane;
	$self->init($distribution, $data, $plane, $space);

	# Return partition
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/space.pl
## ------------------------------------------------------------

sub space {
	my $self = shift;

	# Set value
	$self->{'space'} = shift if (@_);

	# Return value
	return $self->{'space'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/space_box.pl
## ------------------------------------------------------------

sub space_box {
	my $self = shift;

	# Set value
	$self->{'space_box'} = shift if (@_);

	# Return value
	return $self->{'space_box'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/var.pl
## ------------------------------------------------------------

sub var {
	my $self = shift;
	my $var = shift;
	$self->{$var} = shift if (@_);
	return $self->{$var};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Distribution/EHPM/Partition/xchildren.pl
## ------------------------------------------------------------

sub xchildren {
	my $self = shift;
	my $changes = shift;

	# Use replacement for $self in changes, if one exists
	my $replacement = $self->xreplace($changes);
	return $replacement->xchildren($changes)
		if ($replacement);

	# Return children of this node
	my $children = $self->children();
	my $xchildren = [];
	foreach my $child (@$children) {
		push @$xchildren,
			$child->xreplace($changes);
	}

	# Return children
	return $xchildren;
}


1;

1;
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


1;
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


1;

1;
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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::Hierarchy - hierarchy

=head1 DESCRIPTION

DTAG::Learner::Hierarchy - hierarchy.

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Learner::Hierarchy;
use strict;



## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/inside.pl
## ------------------------------------------------------------

sub inside {
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/new.pl
## ------------------------------------------------------------

# Create new learner object

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Return new object
	return $self;
}

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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Learner::UnitBox - unit square hierarchy

=head1 DESCRIPTION

DTAG::Learner::UnitBox - unit square hierarchy.

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Learner::UnitBox;
use strict;

# Specify super class
use base 'DTAG::Learner::Hierarchy';



## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/box_contains.pl
## ------------------------------------------------------------

sub box_contains {
	my $self = shift;
	my $box1 = shift;
	my $box2 = shift;

	# Check whether $box1 contains $box2
	my $dim = $self->dimension();
	for (my $d = 0; $d < $dim; ++$d) {
		return 0 
			if (($box1->[$d][0] > $box2->[$d][0]
				|| ($box1->[$d][1] < $box2->[$d][1])));
	}

	# $box1 contains $box2
	return 1;
} 

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/box_inside.pl
## ------------------------------------------------------------

sub box_inside {
	my $self = shift;
	my $box = shift;
	my $x = shift;

	# Determine whether $x lies in $subspace
	return 0 if (! defined($box));

	# Debug
	#print "box_inside: " . 
	#	DTAG::Interpreter::dumper([$x, $box]) . "\n";

	# Determine whether $x lies in box
	my $dim = $self->dimension();
	for (my $i = 0; $i < $dim; ++$i) {
		return 0 if (($x->[$i] < $box->[$i][0])
			|| ($x->[$i] > $box->[$i][1]));
	}

	# No coordinate was outside box, so $x is inside
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/box_intsct.pl
## ------------------------------------------------------------

sub box_intsct {
	my $self = shift;
	my $box1 = shift;
	my @intsct = ();

	# Return empty list if @_ is empty
	return @intsct if (! @_);

	# Compute intersections
	foreach my $box2 (@_) {
		# Find intersection of the two boxes
		my $dim = $self->dimension();
		my $box = [];
		for (my $d = 0; $d < $dim; ++$d) {
			$box->[$d] = [];
			$box->[$d][0] = max($box1->[$d][0], $box2->[$d][0]);
			$box->[$d][1] = min($box1->[$d][1], $box2->[$d][1]);
			if ($box->[$d][0] >= $box->[$d][1]) {
				$box = undef;
				last();
			}
		}
		
		# Add box to list of boxes
		push @intsct, $box;
	}

	# Return box
	return @intsct;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/box_simplify_union.pl
## ------------------------------------------------------------

sub box_simplify_union {
	my $self = shift;

	my @union = ();

	# Simplify union by removing empty boxes or boxes contained in
	# other boxes
	foreach my $box (@_) {
		# Skip empty boxes
		next() if (! defined($box));

		# Check that box isn't contained in any other union
		my $skip = 0;
		for (my $i = 0; $i < scalar(@union); ++$i) {
			if ($self->box_contains($union[$i], $box)) {
				$skip = 1;
				last();
			}
		}
		next() if ($skip);

		# Remove everything from union contained in $box
		for (my $i = 0; $i < scalar(@union); ++$i) {
			if ($self->box_contains($box, $union[$i])) {
				# Remove box from union
				splice(@union, $i, 1);
				--$i;
			}
		}

		# Add box to union
		push @union, $box;
	}

	# Return simplified union
	return @union;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/branching.pl
## ------------------------------------------------------------

sub branching {
	my $self = shift;
	$self->{'branching'} = shift if (@_);
	return $self->{'branching'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/dimension.pl
## ------------------------------------------------------------

sub dimension {
	my $self = shift;
	$self->{'dimension'} = shift if (@_);
	return $self->{'dimension'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/inside.pl
## ------------------------------------------------------------

sub inside {
	my $self = shift;
	my $subspace = shift;
	my $x = shift;

	# Determine whether $x lies in $subspace
	return $self->box_inside($self->space2box($subspace), $x);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/integrate.pl
## ------------------------------------------------------------

sub integrate {
	my $self = shift;
	my $fspec = shift;
	my $box = shift;
	my $nmax = shift || $self->nmax();

	# Find function $f
	my $f = (ref($fspec) eq 'CODE') ? $fspec : sub {$fspec->f(shift)};

	# Compute box and number of data points in each dimension
	my $dim = $self->dimension();
	my $k = int($nmax ** (1 / $dim));

	# Find size of subspace
	my $size = 1;
	for (my $d = 0; $d < $dim; ++$d) {
		$size *= $box->[$d][1] - $box->[$d][0];
	}
	return $size;

	# Evaluate midpoint if $k <= 1
	my $x = [];
	if ($k <= 1) {
		for (my $i = 0; $i <= $#$box; ++$i) {
			$x->[$i] = ($box->[$i][0] + $box->[$i][1]) / 2;
		}
		return &$f($x) * $size;
	}

	# Return integral of function over subspace
	my $sum = 0;
	my $n = $k ** $dim;
	for (my $i = 0; $i < $n; ++$i) {
		# Create data vector
		for (my $d = 0; $d < $dim; ++$d) {
			my $idim = int($i / ($k ** $d) + 0.5) % int(($k ** ($d+1)) + 0.5);
			my $epsilon = $idim / ($k - 1);
			$x->[$d] = $epsilon * $box->[$d][0] 
				+ (1 - $epsilon) * $box->[$d][1];
		}

		# Evaluate function on vector
		$sum += &$f($x);
	}

	# Return integral
	return $sum * $size / $n;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/max.pl
## ------------------------------------------------------------

=item max($a, $b) = $max

Return the maximum of $a and $b.

=cut

sub max {
	return ($_[0] > $_[1]) ? $_[0] : $_[1];
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/min.pl
## ------------------------------------------------------------

=item min($a, $b) = $min

Return the minimum of $a and $b.

=cut

sub min {
	return ($_[0] < $_[1]) ? $_[0] : $_[1];
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/new.pl
## ------------------------------------------------------------

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Initialize object
	$self->dimension(shift || 2);
	$self->branching(shift || 2);
	$self->nmax(100);

	# Return new object
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/nmax.pl
## ------------------------------------------------------------

sub nmax {
	my $self = shift;
	$self->{'nmax'} = shift if (@_);
	return $self->{'nmax'};
	}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/pbox_diff.pl
## ------------------------------------------------------------

sub pbox_diff {
	my $self = shift;
	my $f = shift;
	my $box = shift;

	# Find union of intersections with $box
	my @union = $self->box_simplify_union($self->box_intsct($box, @_));

	# Return integral
	return $self->integrate($f, $box) 
		- (@union ?  $self->pbox_union($f, @union) : 0);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/pbox_union.pl
## ------------------------------------------------------------

sub pbox_union {
	my $self = shift;
	my $f = shift;
	my $box = shift;
	my @union = @_;

	# Find union of intersections with $box
	my @intsct = $self->box_simplify_union($self->box_intsct($box, @union));

	# Debug
	# print "pbox_union: P(" 
	# 	. join(' U ', map {DTAG::Interpreter::dumper($_)} ($box, @union))
	# 	. ") = P(" . DTAG::Interpreter::dumper($box) 
	# 	. ") + P(" . join(' U ', map {DTAG::Interpreter::dumper($_)} @union) 
	# 	. ") - P(" . join(' U ', map {DTAG::Interpreter::dumper($_)} @intsct) 
	# 	. ")\n";

	# Return integral
	return $self->integrate($f, $box)
		+ (@union ? $self->pbox_union($f, @union) : 0)
		- (@intsct ? $self->pbox_union($f, @intsct) : 0);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/print_box.pl
## ------------------------------------------------------------

sub print_box {
	my $self = shift;
	my $box = shift;

	#return 
	#	join("x",  map {
	#			"[" . join(",", 
	#				map {sprintf("%.4g", $_)} @$_) . "]"
	#		} @$box);

	# Process each dimension
	my @paths = ();
	my $branch = $self->branching();
	foreach my $range (@$box) {
		my ($min, $max) = @$range;
		my $dist = $max - $min;
		my $path = "c";
		while ($dist < 0.99999999) {
			$path .= int($min * $branch + 1 + 1e-15);
			$min = $min * $branch - int($min * $branch);
			$dist *= $branch;
		}
		push @paths, $path;
	}

	# Return path
	return "[" . join(",", @paths) . "]";
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/print_plane.pl
## ------------------------------------------------------------

sub print_plane {
	my $self = shift;
	my $plane = shift;

	return join(" ", map {$_->[0] . ':[' 
		. sprintf("%.4g", $_->[1]) . "," 
		. sprintf("%.4g", $_->[2]) . "]"}
		@$plane);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/random.pl
## ------------------------------------------------------------

sub random {
	my $self = shift;
	my $distribution = shift;
	my $n = shift || 10;
	my $seed = shift;

	# Seed random generator, if requested
	srand($seed) if ($seed);

	# Generate random outcomes
	my $data = DTAG::Learner::Data->new();
	my $observations = $data->{'data'} = [];
	my $outcomes = $data->{'outcomes'} = [];
	for(my $i = 0; $i < $n; ++$i) {
		# Select box randomly
		my $rand = rand();
		my $sum = 0;
		my $k = -1;
		do {
			$sum += $distribution->[++$k][0];
		} until ($sum > $rand);
		my $box = $distribution->[$k][1];

		# Generate uniformly distributed random vector in
		# $distribution->[k] until it lies outside
		# $distribution->[0..k-1]
		my $x = [];
		my $inside = 0;
		while (! $inside) {
			# Generate random number in box
			foreach (my $i = 0; $i < $self->dimension(); ++$i) {
				$x->[$i] = $box->[$i][0] 
					+ rand() * ($box->[$i][1] - $box->[$i][0]);
			}

			# Check that number lies outside $distribution->[0..k-1]
			$inside = 1;
			foreach (my $i = 0; $i < $k; ++$i) {
				if ($self->box_inside($distribution->[$i][1], $x)) {
					$inside = 0;
					last();
				}
			}
		}

		# Add observation to data set
		$data->add($x);
	}

	# Return
	return $data;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/rootbox.pl
## ------------------------------------------------------------

sub rootbox {
	my $self = shift;
	
	# Create unit box
	my $dim = $self->dimension();
	my $box = [];
	for (my $i = 1; $i <= $dim; ++$i) {
		push @$box, [0, 1];
	}

	# Return unit box
	return $box;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/space2box.pl
## ------------------------------------------------------------

# A plane list has the form: [$plane, ...] where $plane = [$dimension,
# $min, $max]

sub space2box {
	my $self = shift;
	my $planes = shift;
	my $box = shift || $self->rootbox();

	# Apply planes one by one
	foreach my $plane (@$planes) {
		my ($dim, $min, $max) = @$plane;
		my $range = $box->[$dim];
		$range->[0] = max($range->[0], $min);
		$range->[1] = min($range->[1], $max);
		return undef if ($range->[0] >= $range->[1]);
	}

	# Return box
	return $box;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/subdata.pl
## ------------------------------------------------------------

sub subdata {
	my $self = shift;
	my $subspace = shift;
	my $data = shift;
	my $mindata = shift || 5;

	# Calculate parameters
	my $dim = $self->dimension();
	my $branch = $self->branching();

	# Calculate box corresponding to planes
	my $box = $self->space2box($subspace);
	return [] if (! defined($box));

	# Find only subdivisions with non-zero counts
	my $hash = {};
	foreach my $d (@{$data->data()}) {
		# Find all planes containing datum
		my $x = $data->outcome($d);
		for (my $i = 0; $i < $dim; ++$i) {
			# Find plane containing datum
			my $min = $box->[$i][0];
			my $max = $box->[$i][1];
			my $pos = int($branch * ($x->[$i] - $min) / ($max - $min));

			# Record datum in plane hash	
			my $list = $hash->{"$i:$pos"} = $hash->{"$i:$pos"} || [];
			push @$list, $d;
		}
	}

	# Create subdata by decreasing frequency
	my $subdata = [];
	foreach my $planeid (sort {scalar(@{$hash->{$b}}) 
			<=> scalar(@{$hash->{$a}})} keys(%$hash)) {
		# Skip subdata if it violates minimum data count
		last() if (scalar(@{$hash->{$planeid}}) <= $mindata);

		# Calculate new plane
		my ($i, $pos) = split(':', $planeid);
		my $min = $box->[$i][0];
		my $max = $box->[$i][1];
		my $newmin = $min + $pos * ($max - $min) / $branch;
		my $newmax = $min + ($pos + 1) * ($max - $min) / $branch;

		# Calculate new data
		my $newdata = $data->clone();
		$newdata->data($hash->{$planeid});
		$newdata->plane([[$i, $newmin, $newmax]]);

		# Store new data as a subdivision
		push @$subdata, $newdata;
	}

	# Return subdata
	return $subdata;
}



## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/subdata2.pl
## ------------------------------------------------------------

sub subdata2 {
	my $self = shift;
	my $subspace = shift;
	my $data = shift;
	my $mindata = shift || 5;

	# Calculate parameters
	my $dim = $self->dimension();
	my $branch = $self->branching();

	# Perform first partition
	my $subdata = $self->subdata($subspace, $data, $mindata);

	# Return all partitions
	return $subdata;
}



## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/subdivisions.pl
## ------------------------------------------------------------

sub subdivisions {
	my $self = shift;
	my $planes = shift;

	# Calculate box corresponding to planes
	my $box = $self->space2box($planes);
	return [] if (! defined($box));

	# Find subdivisions of box
	my $dim = $self->dimension();
	my $branching = $self->branching();
	my $subdivisions = [];
	for (my $i = 1; $i <= $dim; ++$i) {
		# Process each dimension
		my $range = $box->[$i-1];
		my $min = $range->[0];
		my $max = $range->[1];
		my $increment = ($max - $min) / $branching;

		# Split interval into $branching equisized intervals
		for (my $j = 1; $j <= $branching; ++$j) {
			push @$subdivisions, [$i, $min, $min + $increment];
			$min += $increment;
		}
	}

	# Return subdivisions
	return $subdivisions;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Hierarchy/UnitBox/wcover2sub.pl
## ------------------------------------------------------------

sub wcover2sub {
	my $self = shift;
	my $wcover = shift;
	print DTAG::Interpreter::dumper($wcover);

	# Disable numerical integration
	my $nmax = $self->nmax();
	$self->nmax(1);

	# Compute integral of $wcover
	my $cover = [map {$_->[1]} @$wcover];
	my $wcover2 = [];
	for (my $j = 0; $j <= $#$wcover; ++$j) {
		my $volume = $self->pbox_diff(sub {1}, $cover->[$j], 
			@{$j > 0 ? [@$cover[0..$j-1]] : []});
		$wcover2->[$j] = [$wcover->[$j][0] / $volume,
			$wcover->[$j][1]];
	}

	# Print $wcover
	print "WCOVER: " . join(" ", 
		map { $_->[0] . "@" . $self->print_box($_->[1])
		} @$wcover2) . "\n";

	# Re-enable numerical integration
	$self->nmax($nmax);

	# Create subroutine
	my $sub = sub {
		my $x = shift;

		# Find partition containing $x
		my $i;
		for ($i = 0; $i < $#$wcover2 
			&& ! $self->box_inside($wcover2->[$i][1], $x); ++$i) {
		};

		# Compute value in selected partition
		return $wcover2->[$i][0];
	};

	# Return subroutine
	return $sub;
}

1;

1;
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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/HEADER.pl
## ------------------------------------------------------------

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


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/box.pl
## ------------------------------------------------------------

sub box {
	my $self = shift;
	return $self->var('box', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/clean.pl
## ------------------------------------------------------------

sub clean {
	my $self = shift;

	# Delete data
	$self->data([]);

	# Continue recursively with all subspaces
	foreach my $subspace (@{$self->subspaces()}) {
		$subspace->clean();
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/compute.pl
## ------------------------------------------------------------

sub compute {
	my $self = shift;

	# Find number of data
	my $count = scalar(@{$self->data()});
	my $box = '[' . join(', ', @{$self->box()}) . ']';

	print "$box: count=$count\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/compute_partitions.pl
## ------------------------------------------------------------

sub compute_partitions {
	my $self = shift;

	# Find parameters of remaining space
	my $box = $self->box();
	my $data = $self->rdata();
	my $phat = $self->rphat();
	my $weight = $self->rweight();
	my $mass = $weight * $phat;
	my $count = $self->count();

	# Exit if number of data is too small
	return [] if (scalar(@$data) < $mincount);

	# Optimal partition
	my $opt_val = 0;
	my $opt_pdata = undef;

	# For each dimension, try all immediate subtypes
	my $partitions = [];
	for (my $dim = 0; $dim < scalar(@$box); ++$dim) {
		# Find type in dimension $dim
		my $type = $box->[$dim];
		my $subtypes = $lexicon->subtypes($type);

		# Partition data for dimension $dim
		my $partition = $self->partition_data($data, $dim, $subtypes);
		my $sbox = [@$box];			

		# Create partition consisting of all subspaces with count >=
		# $mincount, and lump together all spaces with count <
		# $mincount into one big default space
		foreach my $s (@$subtypes) {
			my $scount = scalar(@{$partition->{$s}});
			if (scalar($scount >= $mincount)) {
				# Calculate prior probability of subspace
				$sbox->[$dim] = $s;
				my $pdata = [$dim, $s, 
					@{$self->split_params($sbox, $partition->{$s})}];
				my $val = $pdata->[2];

				# Save partition if $sphat and $rphat are legal
				push @$partitions, $pdata
					if ($pdata->[3] != 0 && $pdata->[4] != 0);

				# Find optimal partition
				if ($val > $opt_val) {
					$opt_val = $val;
					$opt_pdata = $pdata;
				}
			}
		}
	}

	# Return partitions, with optimal partition as first element
	return $opt_pdata
		? [$opt_pdata, grep {$_ != $opt_pdata} @$partitions]
		: [];
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/compute_phat.pl
## ------------------------------------------------------------

# Calculate cdf of this space minus all superiors and subspaces
sub compute_phat {
	my $self = shift;
	my $space = shift;
	
	# Find superiors if $space is empty
	if (! $space) {
		my $box = $self->box();
		my @superiors = map {$_->box()} 
			(@{$self->subspaces()}, @{$self->superiors()});
		my $n = scalar(@superiors);
		if ($n >= 1) {
			$space = ['-', $self->box(), @superiors];
		} else {
			return &$prior($box);
		}
	}

	# Reduce space
	my $op = $space->[0];
	if ($op ne '-' && $op ne '+') {
		# Space is a simple box
		return &$prior($space);
	} else {
		# Space is composite
		#     phat(A1-(A2+..+An)) := phat(A1)-phat(A1 & (A2+...+An))
		#     phat(A1 + ... + An) 
		#         = phat(A1) + phat(A2+...+An) - phat(A1 & (A2+...+An))
		my $n = scalar(@$space) - 1;
		my $a1 = $space->[1];
		my $phat = &$prior($a1);

		# In set union, add phat(A2+...+An)
		if ($op eq '+') {
			# Add union A2+...+An
			$phat += $self->compute_phat(
				($n <= 2) ? $space->[2] : ['+', @{$space}[2..$n]]);
		} 

		# Subtract union (A1&A2)+...+(A1&An)
		my $union = ['+'];
		my $intsct;
		for (my $i = 2; $i <= $n; ++$i) {
			# Find intersection of A1 and Ai, and save it if non-empty
			$intsct = $self->intsct($a1, $space->[$i]);
			push @$union, $intsct
				if ($intsct);
		}
		if (scalar(@$union) > 2) {
			$phat -= $self->compute_phat($union);
		} elsif (scalar(@$union) == 2) {
			$phat -= &$prior($union->[1]);
		}
			
		# Compute phat
		return $phat;
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/confidence.pl
## ------------------------------------------------------------

sub confidence {
	$confidence = shift if (@_);
	return $confidence;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/count.pl
## ------------------------------------------------------------

sub count {
	my $self = shift;
	return scalar(@{$self->data()});
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/data.pl
## ------------------------------------------------------------

sub data {
	my $self = shift;
	$self->{'data'} = $self->{'rdata'} = shift if (@_);
	return $self->{'data'};
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/disparity.pl
## ------------------------------------------------------------

sub disparity {
	my $self = shift;
	my $gtest = shift;

	# Calculate test value
	my $rho = 0;
	while (@_) {
		my $p = shift;
		my $pi = shift;
		$rho += &$gtest($p / $pi - 1) * $pi;
	}

	# Return test value
	return $rho;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/expected.pl
## ------------------------------------------------------------

sub expected {
	my $self = shift;
	return $self->var('expected', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/filter.pl
## ------------------------------------------------------------

sub filter {
	my $self = shift;
	my $data = shift;
	my $box = shift || $self->box();

	# Filter data through box
	my ($i, $ok);
	my $included = [];
	my $excluded = [];
	foreach my $d (@$data) {
		# Check each dimension of $d
		$ok = 1;
		for (my $i = 0; $i < scalar(@$box); ++$i) {
			if (! grep {$_ eq $box->[$i]} 
					($d->[$i], @{$lexicon->{'super'}{$d->[$i]} || []})) {
				$ok = 0;
				last();
			}
		}

		# Save example if it survived filter
		if ($ok) {
			push @$included, $d;
		} else {
			push @$excluded, $d;
		}
	}

	# Return list of included and excluded data
	return [$included, $excluded];
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/gfunction.pl
## ------------------------------------------------------------

sub gfunction {
	$gfunction = shift if (@_);
	return $gfunction;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/intsct.pl
## ------------------------------------------------------------

sub intsct {
	my $self = shift;
	my $box1 = shift;
	my $box2 = shift;
	my $intsct = [];

	# Find intersection of boxes
	my $type;
	for (my $i = 0; $i < scalar(@$box1); ++$i) {
		# Find intersection of coordinates
		$type = $lexicon->intsct($box1->[$i], $box2->[$i]);
		return undef if (! $type);

		# Save intersected coordinates
		push @$intsct, $type;
	}
	return $intsct;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/learn.pl
## ------------------------------------------------------------

sub learn {
	my $self = shift;
	print $self->print_split() . "\n";
	
	# Continue subpartitioning space until there are no more partitions
	my $partitions = $self->compute_partitions();
	while (@$partitions) {
		# Find optimal partition and its parameters
		my $partition = $partitions->[0];
		my $moved = $partition->[2];

		if (abs($moved) < $minmoved / $total) {
			$partitions = [];
		} else {
			# Split space with partition
			my $subspace = $self->split(@$partition);

			# Split subspace recursively
			$subspace->learn();

			# Compute new set of partitions for this space
			$partitions = $self->compute_partitions();
		}
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/lexicon.pl
## ------------------------------------------------------------

sub lexicon {
	$lexicon = shift if (@_);
	return $lexicon;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/mass.pl
## ------------------------------------------------------------

sub mass {
	my $self = shift;
	return $self->var('mass', @_) || 0;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/mincount.pl
## ------------------------------------------------------------

sub mincount {
	$mincount = shift if (@_);
	return $mincount;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/minmoved.pl
## ------------------------------------------------------------

sub minmoved {
	$minmoved = shift if (@_);
	return $minmoved;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/moved.pl
## ------------------------------------------------------------

sub moved {
	my $self = shift;
	return $self->var('moved', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/new.pl
## ------------------------------------------------------------

# Create new Space object: Space->new($super, $box, $data)
sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Read input parameters
	my $box = shift;
	my $super = shift;
	my $data = shift;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Save parameters
	$self->box($box);
	$self->super($super) if ($super);
	$self->data($data) if ($data);

	# Save count if $super is undefined
	total(scalar(@$data)) if (! defined($super));

	# Set parameters to default values
	$self->subspaces([]);
	$self->weight(1);
	$self->phat(1);
	$self->moved(1);
	$self->pphat(1);
	$self->pweight(1);
	$self->prphat(0);
	$self->prweight(0);

	# Return new object
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/new_data.pl
## ------------------------------------------------------------

sub new_data {
	my $self = shift;
	my $data = shift;
	my $fdata = $self->filter($data);
	$self->data($fdata->[0]);
	$self->rdata($fdata->[0]);
	return $fdata->[1];
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/partition_data.pl
## ------------------------------------------------------------

sub partition_data {
	my $self = shift;
	my $data = shift;
	my $dim = shift;
	my $types = shift;

	# Initialize array with data
	my $partition = {};
	foreach my $t (@$types) {
		$partition->{$t} = [];
	}

	# Sort data into array
	foreach my $d (@$data) {
		my $dtype = $d->[$dim];
		my $supers = $lexicon->{'super'}{$d->[$dim]} || [];
		foreach my $t (@$types) {
			if (grep {$_ eq $t} ($dtype, @$supers)) {
				push @{$partition->{$t}}, $d;
				last();
			}
		}
	}

	# Return hash with new data
	return $partition;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/path.pl
## ------------------------------------------------------------

sub path {
	my $self = shift;
	my $path = shift;

	# Return space if path is empty
	return $self if (! @$path);
	
	# Go to child path
	my $child = shift(@$path);
	my $subspaces = $self->subspaces();
	my $subspace = $subspaces->[$child-1];
	return $subspace->path($path);
}



## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/pcount.pl
## ------------------------------------------------------------

sub pcount {
	my $self = shift;
	return $self->pweight() * $self->pphat() * $total;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/phat.pl
## ------------------------------------------------------------

sub phat {
	my $self = shift;
	$self->{'phat'} = $self->{'rphat'} = shift if (@_);
	return $self->{'phat'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/postscript.pl
## ------------------------------------------------------------

sub postscript {
	my $self = shift;

	# Find all terminal boxes in space
	my @terminals;
}

sub terminals {
	my $self = shift;
	my $terminals = shift || [];

	# Find terminals from all subspaces
	my @subspaces = @{$self->subspaces()};
	foreach my $subspace (@subspaces) {
		$subspace->terminals($terminals);
	}

	# This space is a terminal if it has no subspaces
	push @$terminals, $self
		if (! @subspaces);

	# Return terminals
	return $terminals;
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/pphat.pl
## ------------------------------------------------------------

sub pphat {
	my $self = shift;
	$self->{'pphat'} = shift if (@_);
	return $self->{'pphat'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/print.pl
## ------------------------------------------------------------

sub print {
	my $self = shift;
	my $indent = shift || 0;

	# Print self
	my $string = "\n" . (" " x $indent) 
		. "box=" . $self->print_box() 
		. " moved=" . $self->moved() 
		. "\n" . (" " x $indent)
		. "count=" . $self->count()
		. " weight=" . $self->weight() 
		. " phat=" . $self->phat() 
		. "\n" . (" " x $indent)
		. "rcount=" . $self->rcount()
		. " rweight=" . $self->rweight()
		. " rphat=" . $self->rphat() 
		. "\n" . (" " x $indent) 
		. "mass=" . ($self->weight() * $self->phat())
		. " rmass=" . ($self->rweight() * $self->rphat())
		. "\n";

	return $string;
}

sub print_all {
	my $self = shift;
	my $indent = shift || 0;
	my $string = $self->print($indent);

	# Print subspaces
	foreach my $subspace (@{$self->subspaces}) {
		$string .= $subspace->print_all($indent + 4);
	}

	return $string;
}

sub print_tree {
	my $self = shift;
	my $indent = shift || 0;
	my $string = (" " x $indent) 
		. $self->print_box() . ": "
		. sprintf(" w=%.4g wr=%.4g (c=%.4g ec=%.4g p=%.4g)", 
			$self->weight(),
			$self->rweight(), $self->count(),
			$self->pweight() * $self->phat() * $total,
			$self->pweight() * $self->pphat() * $total
		) . "\n";

	# Print subspaces
	foreach my $subspace (@{$self->subspaces}) {
		$string .= $subspace->print_tree($indent + 4);
	}

	return $string;
}

sub spaces {
	my $self = shift;
	my $spaces = shift || [];

	# Insert space itself on list
	push @$spaces, $self;

	# Insert all subspaces on list
	foreach my $subspace (@{$self->subspaces}) {
		$subspace->spaces($spaces);
	}

	# Return
	return $spaces;
}

sub print_sorted {
	my $self = shift;

	# Find all spaces contained in this space
	my $spaces = $self->spaces();

	# Sort spaces according to absolute moved probability mass
	my @sorted = sort {abs($b->moved()) <=> abs($a->moved())} @$spaces;

	# Print spaces
	my $string = "";
	foreach my $space (@sorted) {
		# Print space
		$string .= $space->print_split() . "\n";
	}

	# Return
	return $string;
}

sub print_splits {
	my $self = shift;
	my $indent = shift || 0;

	my $string = $self->print_split($indent) . "\n";

	# Print subspaces
	foreach my $subspace (@{$self->subspaces()}) {
		$string .= $subspace->print_splits($indent + 4);
	}

	# Return string
	return $string;
}

sub print_split {
	my $space = shift;
	my $indent = shift || 0;
	my $parent = $space->super();

	# Find position of space in parent
	my $pstring = "*";
	my $pos = "*";
	if ($parent) {
		$pstring = $parent->print_box();
		my @siblings = @{$parent->subspaces()};
		for ($pos = 0; $pos < $#siblings; ++$pos) {
			last() if ($siblings[$pos] == $space);
		}
		++$pos;
	}

	# Return string;
	my $istr = " " x $indent;
	return 
		$istr . $space->print_box() . " = $pstring" . "[$pos]\n"
			. $istr . sprintf("weight s=%.4g p=%.4g pr=%.4g.\n"
				. "$istr" . "count s=%.4g se=%.4g ss=%.4g sr=%.4g p=%.4g.\n"
				. "$istr" . "moved=%.4g. phat s=%.4g p=%.4g.\n",
				$space->weight() || 0, $space->pweight() || 1,
					$space->prweight() || 0,
				$space->count() || 0, 
					$space->pweight() * $space->phat() * $total,
					$space->weight() * $space->phat() * $total,
					$space->prweight() * $space->prphat() * $total,
					$space->pcount() || 0,
				$space->moved() || 0,
				$space->phat() || 0, $space->pphat() || 0);
}


sub print_box {
	my $self = shift;
	return "[" . join(", ", @{$self->box()}) . "]";
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/prior.pl
## ------------------------------------------------------------

sub prior {
	$prior = shift if (@_);
	return $prior;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/prphat.pl
## ------------------------------------------------------------

sub prphat {
	my $self = shift;
	$self->{'prphat'} = shift if (@_);
	return $self->{'prphat'};
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/prweight.pl
## ------------------------------------------------------------

sub prweight {
	my $self = shift;
	$self->{'prweight'} = shift if (@_);
	return $self->{'prweight'};
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/pweight.pl
## ------------------------------------------------------------

sub pweight {
	my $self = shift;
	$self->{'pweight'} = shift if (@_);
	return $self->{'pweight'};
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/rcount.pl
## ------------------------------------------------------------

sub rcount {
	my $self = shift;
	return scalar(@{$self->rdata()});
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/rdata.pl
## ------------------------------------------------------------

sub rdata {
	my $self = shift;
	return $self->var('rdata', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/rphat.pl
## ------------------------------------------------------------

sub rphat {
	my $self = shift;
	return $self->var('rphat', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/rweight.pl
## ------------------------------------------------------------

sub rweight {
	my $self = shift;
	return $self->var('rweight', @_); 
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/smooth.pl
## ------------------------------------------------------------

sub smooth {
	$smooth = shift if (@_);
	return $smooth;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/split.pl
## ------------------------------------------------------------

sub split {
	# Arguments
	my $self = shift;
	my $dim = shift;
	my $subtype = shift;

	# Compute boxes
	my $box = $self->box();
	my $sbox = [@$box];
	$sbox->[$dim] = $subtype;

	# Divide data between subspace and its parent
	my ($sdata, $rdata) = @{$self->split_data($self->rdata(), $dim, $subtype)};

	# Retrieve parameters
	my @args = @_;
	if (scalar(@args) != 5) {
		@args = @{$self->split_params($sbox, $sdata)};
	}
	my ($moved, $sweight, $rweight, $sphat, $rphat) = @args;

	# Create new subspace 
	my $subspace = Space->new($sbox, $self); 
	$subspace->super($self);
	push @{$self->subspaces()}, $subspace;

	# Set parameters in subspace
	$subspace->data($sdata);
	$subspace->phat($sphat);
	$subspace->weight($sweight);
	$subspace->moved($moved);
	$subspace->pweight($self->rweight());
	$subspace->pphat($self->rphat());
	$subspace->prweight($rweight);
	$subspace->prphat($rphat);
	$subspace->splitdim($dim);
	$subspace->splittype($subtype);

	# Set parameters in parent space
	$self->rdata($rdata);
	$self->rphat($rphat);
	$self->rweight($rweight);

	# Return subspace
	return $subspace;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/split_data.pl
## ------------------------------------------------------------

sub split_data {
	my $self = shift;
	my $data = shift;
	my $dim = shift;
	my $type = shift;

	# Initialize array with data
	my $included = [];
	my $excluded = [];

	# Sort data into arrays
	foreach my $d (@$data) {
		my $dtype = $d->[$dim];
		my $supers = $lexicon->{'super'}{$d->[$dim]} || [];
		if (grep {$_ eq $type} ($dtype, @$supers)) {
			push @$included, $d;
		} else {
			push @$excluded, $d;
		}
	}

	# Return hash with new data
	return [$included, $excluded];
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/split_params.pl
## ------------------------------------------------------------

sub split_params {
	my $self = shift;
	my $sbox = shift;
	my $sdata = shift;

	# Calculate parent properties
	my $phat = $self->rphat();
	my $weight = $self->rweight();
	my $count = scalar(@{$self->rdata()}) + $smooth;

	# Return if $phat is zero
	return [0, 0, 0, 0, 0]
		if (abs($phat) < 1e-250);

	# Calculate prior probability of subspaces
	my @superiors = map {$_->box()}
		(@{$self->subspaces()}, @{$self->superiors()});
	my $sphat = @superiors
		? $self->compute_phat(['-', $sbox, @superiors])
		: $self->compute_phat($sbox);
	my $rphat = $phat - $sphat;

	# Validity check
	$sphat = 0 if ($sphat <= 0);
	$rphat = 0 if ($rphat <= 0);

	# Calculate counts in the two subspaces
	my $scount = scalar(@$sdata) + $smooth * $sphat / $phat;
	my $rcount = $count - $scount;
	my $mass = $phat * $weight;
	my $smass = $scount / $count * $mass;
	my $rmass = $rcount / $count * $mass;
	my $sweight = ($sphat > 0) ? $smass / $sphat : 0;
	my $rweight = ($rphat > 0) ? $rmass / $rphat : 0;
	my $moved = $smass - $weight * $sphat;

	# Return parameters
	return [$moved, $sweight, $rweight, $sphat, $rphat];
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/splitdim.pl
## ------------------------------------------------------------

sub splitdim {
	my $self = shift;
	return $self->var('splitdim', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/splittype.pl
## ------------------------------------------------------------

sub splittype {
	my $self = shift;
	return $self->var('splittype', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/subfactors.pl
## ------------------------------------------------------------

sub subfactors {
	my $self = shift;
	return $self->var('subfactors', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/subspaces.pl
## ------------------------------------------------------------

sub subspaces {
	my $self = shift;
	return $self->var('subspaces', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/super.pl
## ------------------------------------------------------------

sub super {
	my $self = shift;
	return $self->var('super', @_)
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/superiors.pl
## ------------------------------------------------------------

sub superiors {
	my $self = shift;
	my $superiors = [];

	# Find superiors = older siblings of node, parent, grandparent, etc.
	my $child = $self;
	my $parent = $self->super();
	while($parent) {
		foreach my $sibling (@{$parent->subspaces()}) {
			if ($sibling == $child) {
				last();
			} else {
				push @$superiors, $sibling;
			}
		}
		$child = $parent;
		$parent = $parent->super();
	}

	# Return superiors
	return $superiors;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/test.pl
## ------------------------------------------------------------

sub test {
	my $self = shift;
	return $self->var('test', @_);
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/total.pl
## ------------------------------------------------------------

sub total {
	$total = shift if (@_);
	return $total;
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/value.pl
## ------------------------------------------------------------

sub value {
	my $self = shift;
	my $box = shift;

	# Check whether $box matches any of subspaces
	foreach my $subspace (@{$self->subspaces()}) {
		# Return weight calculated by first subspace that matches box
		return $subspace->value($box)
			if ($lexicon->intsct(
				$subspace->splittype(), 
				$box->[$subspace->splitdim()])); 
	}

	# No subspace matched: return default weight
	return $self->rweight();
}

## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/var.pl
## ------------------------------------------------------------

# Selector methods
sub var {
	my $self = shift;
	my $var = shift;
	$self->{$var} = shift if (@_);
	return $self->{$var};
}


## ------------------------------------------------------------
##  auto-inserted from: Learner/Space/weight.pl
## ------------------------------------------------------------

sub weight {
	my $self = shift;
	$self->{'weight'} = $self->{'rweight'} = shift if (@_);
	return $self->{'weight'};
}


1;

1;
