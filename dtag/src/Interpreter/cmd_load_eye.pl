sub cmd_load_eye {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $multi = shift;

	# Open tag file
	open("XML", "< $file") 
		|| return error("cannot open eye-file for reading: $file");
	CORE::binmode("XML", $self->binmode()) if ($self->binmode());
	
	# Close current graph, if unmodified
	if (! $multi) {
		# Close old graph and create new graph
		$self->cmd_load_closegraph($graph);
		$graph = DTAG::Graph->new($self);
		$graph->file($file);
		push @{$self->{'graphs'}}, $graph;
		$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	}
	my @edges = ();

	# Read XML file line by line
	my $varnames = {};
	my $lineno = 0;
    while (my $line = <XML>) {
        chomp($line);
		my $n = Node->new();
		my $pos = $graph->size();

		# Record line number and source
		if ($multi) {
			++$lineno;
			$n->var('_source', "$file:$lineno");
		}

		# Process <W> tag
		if ($line =~ /^\s*<E(.*)\/>\s*/) {
			my $varstr = $1;
			my $vars = $self->varparse($graph, $varstr, 0);
			my $input = "";
			$n->input($input);
			$n->type("E");
			$graph->node_add($pos, $n);
			foreach my $var (keys(%$vars)) {
				$varnames->{$var} = 1;
				$n->var($var, $graph->xml_unquote($vars->{$var}));
			}
		} else {
			# Comment line: insert as verbatim node
			$n->input($line);
			$n->comment(1);
			$graph->node_add($pos, $n);

			# Process comment, if it represents inline dtag command
			if ($line =~ /^\s*<!--\s*<dtag>(.*)<\/dtag>\s*-->\s*$/) {
				$self->do($1) if ($self->unsafe());
			}
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Insert varnames as permitted varnames
	foreach my $var (keys(%$varnames)) {
		$graph->vars()->{$var} = undef 
			if (! exists $graph->vars()->{$var});
	}

	# Close XML file
	close("XML");
	$self->cmd_return($graph);
	return 1;
}
