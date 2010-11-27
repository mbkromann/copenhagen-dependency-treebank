my $key_names = "123456789abcdefghijklmnopqrstuvwxyz";
my $broken_ReadKey = 1;

sub cmd_find {
	my $self = shift;
	my $graph = shift;
	my $cmd = shift;

	# Process options
	my $time = - time();
	my $match = 0;

	# Parse query string
	$cmd =~ s/^\s*//;
	my $cmd2 = "$cmd";
	my $parse = $self->query_parser()->FindExpression(\$cmd2);
	print "dump: " . dumper($parse) . "\n"
		if (! (defined($parse) && defined($parse->{'options'}) 
			&& ! $parse->{'options'}{'dump'}));

	if ($cmd2) {
		# String was not parsed completely
		error("Illegal search query: error in \"$cmd2\"");
		return 1;
	}

	# Retrieve options, query, and actions
	my $options = $parse->{'options'};
	my $query = $parse->{'query'};
	my $actions = $parse->{'actions'};
	print "Actions: \n";
	foreach my $action (@$actions) {
		print "\t" . $action->print() . "\n";
	}
	print "\n";

	my $timeout = $options->{'maxtime'} || "0";
	my $matchout = $options->{'maxmatch'} || "0";
	my $debug = $options->{'debug'};
	my $debug_parse = $options->{'debug_parse'};
	my $debug_dnf = $options->{'debug_dnf'};
	my $corpus = $options->{'corpus'};
	my $safe = $options->{'safe'};
	my $varkeys = $options->{'vars'} || {};

	# Print debugging output of parse
	if ($debug_parse || $debug_dnf || $debug) {
		$self->print("find", "result", 
			"input=$cmd\n"
			. (defined($timeout) ? "maxtime=$timeout\n" : "")
			. (defined($matchout) ? "maxmatch=$matchout\n" : "")
			. ((ref($query) && UNIVERSAL::isa($query, 'HASH'))
				? "vars=" . join(" ", sort(keys(%{$query->unbound({})})))
					. "\n" 
				: "")
			. "varkeys=" . join(" ", map {$_ . ($varkeys->{$_} ? "@" . $varkeys->{$_} : "")}
					sort(keys(%$varkeys))) . "\n"
			. ("query=" 
				. ((ref($query) && UNIVERSAL::can($query, "print")) 
					? $query->print() : dumper($query)) . "\n"));
		return 1 if ($debug_parse);
	}

	# Check that all variables have a valid key unless the graph is a Graph.
	if (! UNIVERSAL::isa($graph, "DTAG::Graph")) {
		foreach my $var (keys(%{$query->unbound({})})) {
			if (! $graph->graph($varkeys->{$var})) {
				error("When searching an alignment, you must use the -vars option\n" 
					. "to specify keys for all variables in the query.");
				return 1;
			}
		}
	}
	my $abort = 0;
	foreach my $var (keys(%$varkeys)) {
		my $key = $varkeys->{$var};
		my $keygraph = $graph->graph($key);
		if (! defined($keygraph)) {
			error("Undefined graph key \"" . (defined($key) ? $key : "") 
				. "\" for variable $var!");
			$abort = 1;
		}
	}
	return 1 if ($abort);

	# Reduce query string to disjunctive normal form
	my $dnf = ref($query) ? $query->dnf() : undef;
	my $oquery = $query->pprint();
	my $rquery = $dnf->pprint();
	$self->print("find", "result",
		"Executing query\n\n\t$oquery\n\n" .
			($oquery ne $rquery ? "as query\n\n\t$rquery\n\n"
				: ""));
	return 1 if ($debug_dnf);

	# Reset found matches and disable follow
	my $matches = $self->{'matches'} = {};
	my $maxsols = 100000;				# Maximal number of full solutions
	my $noview = $self->var("noview");
	$self->var("noview", 1);

	# Solve DNF-query for all files in corpus
	my $iostatus = $|; $| = 1; my $c = 0;
	my $progress = "";
	my $findfiles = $corpus ? $self->{'corpus'} : [$self->graph()->id()];
	my $count = 0;
	my $display = 1;
	my $ask = $self->interactive() && ! $options->{'replace-all'};
	my $laststatus = time() - 1;
	foreach my $f (@$findfiles) {
		# Load new file from corpus, if this is a corpus search 
		$self->cmd_load($graph, undef, $f) 
			if ($corpus);
		$graph = $self->graph();

		# Print progress report 
		if ($corpus && ! $self->quiet()) {
	 		if (time() > $laststatus + 0.5 ) {
				$laststatus = time();
				my $blank = "\b" x length($progress);
				my $percent = int(100 * $c / (1 + $#$findfiles));
				$progress = 
					sprintf('Searched %02i%%. Elapsed: %s. ETA: %s. Matches: %i.',
					$percent,
					seconds2hhmmss(time()+$time),
					seconds2hhmmss(int((100-$percent) 
							/ ($percent || 1) * (time()+$time))),
					$count);
				$self->print("find", "status", $blank . $progress);
			}
			++$c;
		}

		# Solve DNF-query for all conjunctions in disjunction
		foreach my $and (@{$dnf->{'args'}}) {
			# Push all solutions onto list of matches
			my $solutions = 
				$and->solve($graph, $maxsols, 
					{'vars' => $varkeys});
			if (@$solutions) {
				$matches->{$f} = [] if (! $matches->{$f});

				# Process solutions
				foreach my $s (@$solutions) {
					push @{$matches->{$f}}, $s;
					$count += 1;
				}
			}

			# Abort if timeout and matchout have been exceeded
			$self->abort(1) if (($matchout && $count > $matchout) 
				|| ($timeout && (time()+$time) > $timeout));

			# Catch abort request
			last() if $self->abort();
		}

		# Replace all matches in $matches->{$f}
		foreach my $action (@$actions) {
			my $choice = "N";
			foreach my $binding (@{$matches->{$f}}) {
				# Select replace operation
				$choice = "Y";
				if ($ask && $action->ask()) {
					# Update graph
					++$match;
					$self->cmd_goto($graph, "M$match");

					# Print replace operations
					print "Replace operations for ",
						$self->print_match($match, $f, $binding), "\n",
						"    ", $action->string(), "\n",
						"    [Y]es [N]o [A]ll [Q]uit [E]dit\n";

					# Read choice
					$choice = " ";
					while (ReadKey(-1)) { };		# ignore any input
					while ("YNAQE" !~ /$choice/) {
						$choice = ($broken_ReadKey ? getc() : ReadKey(-1)) 
							|| "_";
						print "[$choice]";
						sleep(1);
					}
					#ReadMode('normal') if (! $broken_ReadKey); 
				}

				# Process choice: AYN0
				if ($choice eq "N" || $choice eq "0") { next() };
				if ($choice eq "Q") { last() };
				if ($choice eq "A") { $ask = 0; print "\n"; };

				# Manual edit or automatic replacement
				if ($choice eq "E") {
					# Manual edit
					$self->var("noview", 0);
					$self->loop();
					$self->var("noview", 1);
					next();
				} elsif ($choice eq "A" || $choice eq "Y") {
					$binding->{'$FILE'} = $graph->file();
					$binding->{'$GRAPH'} = $f;
					$action->do($graph, $binding, $self, $ask);
				}

				# Show result and wait for keypress
				last() if ($self->abort());
			}

			# Save file if corpus replace
			$self->cmd_save_tag($graph)
				if ($corpus && $graph->mtime());

			# Quit if requested by Q or abort
			last() if ($choice eq "Q" || $self->abort());
		}

		# Abort on request
		last() if ($self->abort());
	}
	print "\b" x length($progress)
		. " " x length($progress) 
		. "\b" x length($progress)
			if ($corpus && ! $self->quiet());
	$| = $iostatus;

	# Close actions
	foreach my $action (@$actions) {
		$action->close();
	}

    # Print search statistics
	$time += time();
	print "$count matches found in " . seconds2hhmmss($time) 
		. " for query \"$cmd\".\n" if (! $self->quiet());


	# Restore viewing
	$self->var("noview", 0);

	# Show first match
	$self->cmd_goto($graph, 'M1') if ($count);

	# Return
	return 1;
}

