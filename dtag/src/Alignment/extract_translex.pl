# $self->extract_translex($interpreter): extract transfer lexicon
# rules and store them in interpreter's transfer lexicon 

my $debug = 0;

sub extract_translex {
	# Parameters
	my ($self, $interpreter) = @_;

	# Translation units hash
	my $tunits = {};

	# Merge all word-aligned nodes
	print "Merge alignment edges\n" if ($debug);
	$self->merge_alignments($tunits);

	# Merge cycles for each tunit in $tunits
	print "Merge components\n" if ($debug);
	foreach my $n (map {$_->[0]} uniq(sort(values(%$tunits)))) {
		# Merge component involving the first node $n in each tunit
		$self->tunit_merge_component($tunits, $n);
	}

	# Process tunits in bottom-up order. Note: the tunit graph is
	# guaranteed to be acyclic now, so bottom-up order makes sense!
	# Tunits are referred to by means of the first node in the tunit.
	my $done = {};
	my @todo = uniq(sort(map {$_->[0]} values(%$tunits)));
	while (@todo) {
		# Take off most recent node from stack 
		my $n = pop(@todo);
		my $tunit = $tunits->{$n};
		my $tunit_str = tunit2str($tunits->{$n});

		# Debug
		print "Process ", int2str($n), ":\n" if ($debug);

		# Skip tunit if already finally done
		next() if (($done->{$tunit_str} || 0) & 2);

		# Mark tunit as visited
		$done->{$tunit_str} = 1;

		# Find all unprocessed child tunits in the tunit DAG 
		my @children 
			= uniq(sort(
				map {$tunits->{$_}[0]} 
					$self->tunit_dependents($tunits, $n)));
		my @unprocessed 
			= grep {! $done->{tunit2str($tunits->{$_})}} 
				@children;

		# Debug
		print "    children: ",
			join(" ", map {int2str($_)} @children), "\n" if ($debug);
		print "    unprocessed: ",
			join(" ", map {int2str($_)} @unprocessed), "\n" if ($debug);


		# Process all unprocessed child tunits first
		if (@unprocessed) {
			# Add $n with child tunits to stack
			push @todo, ($n, @unprocessed);
		} else {
			print "    merge non-connected components of ", 
				int2str($n), "\n" if ($debug);
			# 0. Merge all non-connected components of $n: For each
			# root node within the component, compute the upwards path
			# to the external root; find the common root path shared by
			# all internal roots, and merge the component with 
			# all non-common nodes on the root path.
			my $paths = {};
			my $shared_path = undef;
			foreach my $nu (@{$tunits->{$n}}) {
				# Compute root path for node $nu
				my $rootpath = $paths->{$nu} = [$self->node_rootpath($nu)];
				print "rootpath($nu): ", join(" ", @$rootpath), "\n"
					if ($debug);
				$shared_path = $rootpath 
					if (! defined($shared_path));

				# Intersect shared path with new root path
				for (my $i = 0; $i <= min($#$rootpath, 
						$#$shared_path); ++$i) {
					if ($rootpath->[$i] != $shared_path->[$i]) {
						$shared_path = [$shared_path->[0..($i-1)]];
					}
				}
			}

			# Compute union of last node in shared path and all
			# rootpaths minus shared path
			my $shared_length = scalar(@$shared_path);
			my $tomerge = {};
			foreach my $nu (@{$tunits->{$n}}) {
				# Add all non-shared nodes in path to $tomerge
				my $rootpath = $paths->{$nu};
				for (my $i = $#$shared_path; $i <= $#$rootpath; ++$i) {
					$tomerge->{$rootpath->[$i]} = 1;
				}
			}
			print "shared: ", $shared_length, "\n"
				if ($debug);

			# Merge all nodes in $tomerge
			foreach my $newnode (keys(%$tomerge)) {
				#merge_tunit($tunits, $n, $newnode);
			}

			print "    merge governors of ", int2str($n), "\n" if ($debug);
			## 1. Merge all governors of $n: First find all governors
			## of $n ...
			my @governors = uniq(sort(
				map {$tunits->{$_}[0]}
					$self->tunit_governors($tunits, $n)));
			print "    governors: ",
				join(" ", map {int2str($_)} @governors), "\n" if ($debug);

			# ... then merge them if there is more than one ...
			my $governor1 = pop(@governors);
			foreach my $governor2 (@governors) {
				merge_tunit($tunits, $governor1, $governor2);
			}

			# ... and finally merge all cycles at the merged governors
			# so that the tunits graph remains acyclic.
			$self->tunit_merge_component($tunits, $governor1) if (@governors);


			## 2. Merge $n with its governor if $n is a monolingual
			## complement
			if ($self->tunit_is_monolingual($tunits, $n)) {
				print "    merge monolingual complement governor of ", 
					int2str($n), "\n" if ($debug);

				# Find any complement governors of the monolingual 
				# tunit $n ...
				my @cgovernors = uniq(sort(
					map {$tunits->{$_}[0]}
						$self->tunit_complement_governors($tunits, $n)));

				# ... then merge $n with its complement governors (if
				# there are any) ...
				foreach my $cgovernor (@cgovernors) {
					merge_tunit($tunits, $n, $cgovernor);
				}

				# ... and finally merge all cycles at the merged governors
				# so that the tunits graph remains acyclic.
				$self->tunit_merge_component($tunits, $n) if (@cgovernors);
			}

			## 3. Mark tunit as finally done
			$done->{$tunit_str} = 3;
		}
	}

	# Debugging output
	if (1 || $debug)  {
		# Print translation units
		print "\nTRANSLATION UNITS\n";
		my @sets = ();
		foreach my $tunit (uniq(sort(values(%$tunits)))) {
			push @sets, join(" ", sort(
				map {int2str($_)} @$tunit));
		}
		print join("\n", sort(@sets)), "\n";
		$interpreter->{'tunits'} = $tunits;
	}

	# Print lexicon
	# ved(X:subj, at:dobj(Y)) <=> know(X:subj, about:pobj(Y))
	if (1 || $debug) {
		$| = 1;
		print "\nTRANSFER RULES\n";
		foreach my $tunit (uniq(sort {$b->[0] <=> $a->[0]} (values(%$tunits)))) {
			# Print transfer unit frames
			my $trule = $self->tunit_cframe_print($tunits, $tunit);
			print "comp[", int2str($tunit->[0]), "]: ",
				$trule, "\n" if (defined $trule);

			# Print transfer adjunct frames

			# Print transfer deletion frames
			
			# Print transfer addition frames
		}
	}
}

sub tunit_cframe_print {
	# Parameters
	my ($self, $tunits, $tunit, $format) = @_;
	$format = 'txt' if (! $format);

	# Find and name variables of tunit
	my $variables = {};
	
	# Find source and target nodes, and exit if one set is empty
	my @snodes = grep {$_ > 0} @$tunit;
	my @tnodes = grep {$_ < 0} @$tunit;
	return undef unless (@snodes && @tnodes);
	 
	# Find dependency structure of the two units
	my $sourcetree = $self->tunit_deptree($tunits, $variables, $format,
		{}, @snodes);
	my $targettree = $self->tunit_deptree($tunits, $variables, $format,
		{}, @tnodes);
	
	# Return cframe
	return (scalar(@$tunit) + 2 * scalar(keys(%$variables))) . " " 
		. $sourcetree . " <=> " . $targettree;
}

sub tunit_deptree {
	# Parameters
	my ($self, $tunits, $variables, $format, $trees, @nodes) = @_;

	# Process all nodes in $nodes
	foreach my $n (@nodes) {
		# Only process each node once
		next() if ($trees->{$n});
		my $n0 = $tunits->{$n}[0];

		# Mark node as visited (will never be used except in cycles)
		$trees->{$n} = "***CYCLE***";

		# Find graph, node, and string
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		my $string = $nodeobj->input();

		# Process all dependent edges of node
		my @args = ();
		foreach my $e (sort {$a->in() <=> $b->in()} @{$nodeobj->out()}) {
			# Ignore non-dependents
			next() if (! $graph->is_dependent($e));

			# Find dependent id
			my $d = node2int($e->in(), $key);
			my $d0 = $tunits->{$d}[0];

			# Process dependent
			if ($tunits->{$n} eq $tunits->{$d}) {
				# Nodes $n and $d belong to the same tunit:
				# recursively process the dependent $d
				$self->tunit_deptree($tunits, $variables, $format,
					$trees, $d);

				# Add dependent to arg-list
				push @args, $e->type() . "=" . $trees->{$d};
			} elsif (grep {$_ == $n0}
					$self->tunit_complement_governors($tunits, $d)) {
				# Dependent is a tunit argument: create new variable
				# if necessary
				if (! $variables->{$d0}) {
					# Add new variable
					$variables->{$d0} = varname($variables);
				}

				# Add dependent to arg-list
				push @args, $e->type() . "=" . $variables->{$d0};
			} 

		}

		# Now create string representation of $n
		$trees->{$n} = lc($string) . 
			(@args ? "(" . join(", ", @args) . ")" : "");
	}

	# Return string representation of root node (=longest string in
	# $trees)
	my @strings = sort {length($b) <=> length($a)} values(%$trees);
	#print "    strings: ", join(" ", @strings), "\n";
	return $strings[0];
}

sub varname {
	my $hash = shift;
	return chr(scalar(keys(%$hash)) + 65);
}
