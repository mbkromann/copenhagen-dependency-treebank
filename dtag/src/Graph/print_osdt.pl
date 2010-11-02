sub print_osdt {
	my $self = shift;
	my $prefix = shift;
	my $viewcount = shift || 0;
	my $nodecount = shift || 0;
	my $nodes2id = shift;
	#$nodes2id = {} if (!defined($nodes2id));

	# Write OSDT header
	my $nodes = "LAYER" . $viewcount++ . " \"$prefix" . "words\"";
	my $deps = "LAYER" . $viewcount++ . " \"$prefix" . "dependency edges\" 0=\"relation\"\n";
	my $sec = "LAYER" . $viewcount++ . " \"$prefix" . "other edges\" 0=\"relation\"\n";

	# Find node features
	my $vars = ["string", sort(keys(%{$self->vars()}))];
	my $cnt = 0;
	foreach my $var (@$vars) {
		my $cleaned = "" . $var;
		$cleaned =~ s/	/\&\#11;/g;
		$nodes .= " " . $cnt++ . "=\"" . $cleaned . "\"";
	}
	$nodes .= "\n";

	# Write OSDT file line by line
	for (my $i = 0; $i < $self->size(); ++$i) {
		my $N = $self->node($i);
		if (! $N->comment()) {
			$nodes2id->{$i} = $nodecount++;
			$nodes .= "  NODE" . $nodes2id->{$i};
			for (my $i = 0; $i <= $#$vars; ++$i) {
				my $value = ($i == 0) ? $N->input() : $N->var($vars->[$i]);
				if (defined($value)) {
					$value = "" . $value;
					$value =~ s/"/\&quot;/g;
					$nodes .= " $i=\"$value\"";
				}
			}
			$nodes .= "\n";
		}
	}

	# Process edges
	for (my $i = 0; $i < $self->size(); ++$i) {
		my $N = $self->node($i);
		if (! $N->comment()) {
			# Process in-edges at node
			foreach my $e (@{$N->in()}) {
				my $nin = $nodes2id->{$e->in()};
				my $nout = $nodes2id->{$e->out()};
				my $type = $e->type();
				if ($self->is_dependent($e)) {
					# Primary in-edge
					$deps .= "  EDGE $nin<$nout 0=\"$type\"\n";
				} else {
					# Other edge
					$sec .= "  EDGE $nin<$nout 0=\"$type\"\n";
				}
			}
		}
	}

	# Save view and node count in nodes2id
	$nodes2id->{'_views'} = $viewcount;
	$nodes2id->{'_nodes'} = $nodecount;

	# Return
	return $nodes . $deps . $sec;
}

