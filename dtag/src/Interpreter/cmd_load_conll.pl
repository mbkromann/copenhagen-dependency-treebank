sub cmd_load_conll {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open tag file
	open("CONLL", "< $file") 
		|| return error("cannot open CONLL-file for reading: $file");
	
	# Close current graph, if unmodified
	$self->cmd_load_closegraph($graph);

	# Create new graph
	$graph = DTAG::Graph->new($self);
	$graph->file($file);
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	$graph->vars()->{'msd'} = undef;

	# Read CONLL file line by line
	my $offset = 0;
	my $edges = [];
	my $pos = 0;
    while (my $line = <CONLL>) {
		# Process CONLL line
        chomp($line);
		my ($ID, $FORM, $LEMMA, $CPOSTAG, $POSTAG, $FEATS,
			$HEAD, $DEPREL, $PHEAD, $PDEPREL) = split(/	/, $line);

		# Create node and add it to graph
		my $n = Node->new();
		my $in = $graph->size();
		if ($line) {
			# Setup node
			$n->input($FORM);
			$n->var('lemma', $LEMMA) if ($LEMMA && $LEMMA ne "_");
			$n->var('cpos', $CPOSTAG) if ($CPOSTAG && $CPOSTAG ne "_");
			$n->var('pos', $POSTAG) if ($POSTAG && $POSTAG ne "_");
			$n->var('feats', $FEATS) if ($FEATS && $FEATS ne "_");
			$n->var('phead', $PHEAD) if ($PHEAD && $PHEAD ne "_");
			$n->var('pdeprel', $PDEPREL) if ($PDEPREL && $PDEPREL ne "_");
			$graph->node_add($in, $n);

			# Create edge
			my $e = Edge->new();
			$e->in($in);
			$e->type($DEPREL || "");
			$e->out($HEAD - $ID + $in);
			push @$edges, $e if ($HEAD);
		} else {
			$n->comment(1);
			$n->input('</s>');
			$offset = $graph->size();
			$graph->node_add($in, $n);
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Add edges
	foreach my $e (@$edges) {
		$graph->edge_add($e) 
			if ($e->out() >= 0);
	}

	# Close CONLL file
	close("CONLL");
	$self->cmd_return($graph);
	return 1;
}
