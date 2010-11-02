

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


