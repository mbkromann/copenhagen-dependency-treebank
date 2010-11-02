sub cmd_relations {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Hash containing all found relations
	my $relations = $self->{'relations'} = 
		{	'cframes' => {},
			'aframes' => {},
		};
	my $cframes = $relations->{'cframes'};

	# Recognizing edges
	my $edges = 
		{	'comp' => 
				sub {my $var = shift; 
					$var =~ /^\[?(.*obj|expl|possd|pred|subj|num.|part)\]?$/ },
			'agov' => 
				sub { my $var = shift; 
					$var =~ /^$/ },
		};

	# Look at each node in graph
	for (my $i = 0; $i < $graph->size(); ++$i) {
		# Skip current node if it is a comment
		my $head = $graph->node($i);
		next() if $head->comment();

		# Find head word and head category
		my $headW = $head->input();
		my $headC = $head->var('msd');

		# Find complement frame at node $i
		my $cframe = [['*', $headC, $headW, $i]];
		foreach my $edge (@{$head->out()}) {
			if (&{$edges->{'comp'}}($edge->type())) {
				my $rel = $edge->type();
				$rel =~ s/\[(.*)\]/$1/g;
				my $comp = $graph->node($edge->in());
				my $compW = $comp->input();
				my $compC = $comp->var('msd');
				
				# Insert complement in complement frame
				push @$cframe, [$rel, $compC, $compW, $edge->in()];

				# Insert complement in complements list
				$cframes->{"# $rel"} = [] if (! $cframes->{"# $rel"});
				push @{$cframes->{"# $rel"}}, 
					[	['#', $headC, $headW, $i], 
						[$rel, $compC, $compW, $edge->in()]];
			}
		}

		# Save complement frame
		my $framename = join(" ", 
			sort(map {my $a = $_->[0]; $a =~ s/\[(.*)\]/$1/g; $a} @$cframe));
		$cframes->{$framename} = [] 
			if (!  $cframes->{$framename});
		push @{$cframes->{$framename}}, $cframe;
	}

	# Save description in file /tmp/dtag-relations
	if ($file) {
		open(REL, ">$file") || 
			return error("cannot open file $file for writing relations");
		my @rel = sort(keys(%{$cframes}));
		foreach my $r (@rel) { 
			# Print relation header
			printf REL "%s=%s\n", 
				scalar(@{$cframes->{$r}}),
				$r;

			# Find relation entries, sorted by first two letters of
			# categories
			my $cats = {};
			foreach my $e (@{$cframes->{$r}}) {
				# Sort complements and find their category string
				my @comps = sort {$a->[0] cmp $b->[0]} @$e;
				my $cat = join(" ", map {($_->[0] || "") . ":" 
					. substr(($_->[1] || ""), 0, 2)} @comps);

				# Sort complements by category string
				$cats->{$cat} = [] if (! $cats->{$cat});
				push @{$cats->{$cat}}, [@comps];
			}

			# Print relation entries
			foreach my $cat (sort(keys(%$cats))) {
				printf REL "\t%s=$cat\n", scalar(@{$cats->{$cat}});
				foreach my $e (@{$cats->{$cat}}) {
					print REL "\t\t" . join(" ", 
						map {"[" . ($_->[2] || "") 
							. ":" . ($_->[1] || ""). "]"} @$e) . "\n";
				}
			}
		}
		close('REL');
	}
}

