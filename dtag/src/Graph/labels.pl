=item $graph->labels($interpreter, $maxlabels) = $labels

Compute set of labels contained in graph (omit label types with more
than $maxvalues different values). Afterwards, $labels is a hash with
the following structure:

	$labels = {	'_vars' => [$var1, ..., $varN],
				'_edges1' => [$edge, ...],
				'_edges2' => [$edge, ...],
				'$var1' => [$label, ...], 	# (if less than $maxlabels labels)
				'$var2' => undef,			# (if more than $maxlabels labels)
				...
			  }
=cut

sub labels {
	# Read parameters
	my $self = shift;
	my $interpreter = shift;
	my $maxlabels = shift || 500;

	# Variables
	my $vars = { };
	my $labels = { };
    my $pos = $self->layout($interpreter, 'pos') || sub {return 0};

	# Find possible variables to include in the graph, and compute
	# their position in the 'vars' regexp.
	my $regexps = [split(/\|/, 
		$self->layout($interpreter, 'vars') || "/stream:.*/|msd|gloss")];
	foreach my $var (keys(%{$self->vars()})) {
		my $m = regexp_match($regexps, $var);
		$vars->{$var} = $m if ($m);
	}

	# Sort labels and initialize $labels hash
	my @sorted = sort {($vars->{$a} <=> $vars->{$b}) || ($a cmp $b)} 
					keys(%$vars);
	map {$labels->{$_} = {}} @sorted;
	
	# Compute possible label values (if fewer than $maxlabels)
	my $size = $self->size();
	for (my $i = 0; $i < $size; ++$i) {
		my $node = $self->node($i);
		if ($node && ! $node->comment()) {
			# Add edge labels to list
			foreach my $e (@{$node->in()}) {
				if (&$pos($self, $e)) {
					# Bottom edge
					$labels->{'_edges2'}{$e->type()} = 1; 
				} else {
					# Top edge
					$labels->{'_edges1'}{$e->type()} = 1; 
				}
			}

			# Add variable values to list
			foreach my $v (@sorted) {
				if (defined($labels->{$v})) {
					# Store variable value
					$labels->{$v}{$self->reformat($interpreter,
						$v, $node->var($v), $self, $i)} = 1;

					# Undefine if number of values exceeds $maxlabels
					$labels->{$v} = undef
						if (scalar(keys(%{$labels->{$v}})) > $maxlabels);
				}
			}
		}

		# Abort if requested
		last() if ($interpreter->abort());
	}

	# Compute new labels hash 
	map {$labels->{$_} = [sort(keys(%{$labels->{$_}}))]} keys(%$labels);
	$labels->{'_vars'} = [@sorted];

	# Return labels hash
	return $labels;
}



