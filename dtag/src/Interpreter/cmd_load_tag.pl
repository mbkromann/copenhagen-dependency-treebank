sub cmd_load_tag {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $multi = shift;

	# Open tag file
	open("XML", "< $file") 
		|| return error("cannot open tag-file for reading: $file");
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
		#if ($line =~ /^\s*<W([^>]*)>([^<]*)<\/W>\s*$/) 
		if ($line =~ /^\s*<W(.*)>(.*)<\/W>\s*$/) {
			# Input line: create node and insert it into text
			my $input = $2;
			my $varstr = $1;
			$n->input($input);
			$graph->node_add($pos, $n);

			# Parse variable string and add variables to node (and
			# variable name list)
			my $vars = $self->varparse($graph, $varstr, 0);
			foreach my $var (keys(%$vars)) {
				if ($var eq "in" || $var eq "out") {
					# Edge specification: create edge if possible
					foreach my $e (split(/\|/, $vars->{$var})) {
						$e =~ /^([+-]?[0-9]+):(\S+)$/;
						my $pos2 = $1+$pos;
						my $etype = $graph->xml_unquote($2);
						my $edge;

						# Create edge
						if ($var eq "in") {
							$edge = Edge->new($pos, $1+$pos, $etype);
						} elsif ($var eq "out") {
							$edge = Edge->new($1+$pos, $pos, $etype);
						}
						
						# Create edge if possible
						if ($pos2 < $pos) {
							$graph->edge_add($edge);
						} elsif ($pos2 == $pos && $var eq "in") {
							push @edges, $edge;
						}
					}
				} else {
					# Ordinary variable
					$varnames->{$var} = 1;
					$n->var($var, $graph->xml_unquote($vars->{$var}));
				}
			}
		} elsif ($line =~ /^\s*<!--\s*<inalign>([\d+]+)\s+([\d+]+)\s+(\S*)<\/inalign>\s*-->\s*$/) {
			# XML comment representing inalign edge
			$self->cmd_inalign($graph, $1, $2, $3);
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

	# Insert unprocessed edges
	foreach my $e (@edges) {
		# Insert edge unless it already exists
		$graph->edge_add($e, 1);
	}

	# Close XML file
	close("XML");
	$self->cmd_return($graph);
	return 1;
}
