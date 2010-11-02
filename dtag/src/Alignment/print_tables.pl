sub print_tables {
	# Parameters
	my $self = shift;
	my $nodecount = shift || 0;
	my $nodeattributes = shift || [];
	my $edgeattributes = shift || [];
	my $globalvars = shift || {};
	my $nodes2id = shift || {};
	my $prefix = shift || "";

	# Specify node and edge attributes
	DTAG::Graph::add_attributes($nodeattributes, "id", "key");
	DTAG::Graph::add_attributes($edgeattributes, "in", "out", "key");

	# Convert dependency graphs in alignment
	my ($nodes, $edges) = ("", "");
	my @keys = sort(keys(%{$self->graphs()}));
	my $keysstring = $prefix . join("", @keys);
	foreach my $key (sort(keys(%{$self->graphs()}))) {
		# Count node and edge attributes
		my $nacount = scalar(@$nodeattributes);
		my $eacount = scalar(@$edgeattributes);

		# Find global node and edge attributes
		my $graph = $self->graph($key);
		$globalvars->{"node:key"} = $key;
		$globalvars->{"edge:key"} = $key;

		# Compute dependency graph tables
		my ($gnodes, $gedges, $gnodecount) = $graph->print_tables($nodecount, 
			$nodeattributes, $edgeattributes, $globalvars, $nodes2id,
			$prefix . "$key");

		# Update tables
		$nodes = add_na_columns($nodes, scalar(@$nodeattributes) - $nacount);
		$edges = add_na_columns($edges, scalar(@$edgeattributes) - $eacount);
		$nodes .= $gnodes;
		$edges .= $gedges;
		$nodecount = $gnodecount;
	}

	# Set file name
    $globalvars->{'node:file'} = $self->file()
        if ($self->file());

	# Convert all many-many alignment edges to formal alignment nodes
	# augmented by n-1 alignment edges
	$globalvars->{"node:key"} = undef;
	foreach my $aedge (@{$self->edges()}) {
		# Decompose alignment edge
		my ($inkey, $outkey) = ($aedge->inkey(), $aedge->outkey());
		my ($inprefix, $outprefix) = ($prefix . $inkey, $prefix . $outkey);
		my ($ingraph, $outgraph) = ($self->graph($inkey), $self->graph($outkey));
		my $innodes = $aedge->inArray();
		my $outnodes = $aedge->outArray();

		# Set variable values
		$globalvars->{'node:key'} = "$outkey->$inkey";
		$globalvars->{'node:id'} = $keysstring . $nodecount;
		$globalvars->{'node:line'} = $aedge->var("lineno");
		$globalvars->{'node:sentence'} = undef;
		$globalvars->{'node:token'} = undef;
		$globalvars->{'edge:key'} = "$outkey->$inkey";
		$globalvars->{'edge:label'} = $aedge->type();
		$globalvars->{'edge:primary'} = undef;

		# Create in-edges
		my $nedges = 0;
		$globalvars->{'edge:out'} = $globalvars->{'node:id'};
		foreach my $inode (@$innodes) {
			my $nodeid = $nodes2id->{$inprefix .  $inode};
			if (defined($nodeid)) {
				$globalvars->{'edge:in'} = $nodeid;
				$edges .= DTAG::Graph::create_R_table_row($edgeattributes, $aedge, $globalvars, 'edge:');
				++$nedges;
			} else {
				my $insign = signature($ingraph, $innodes, "_input");
				print "Undefined node " . $inprefix . $inode . " in "
					. $aedge->string() . " in " .  $globalvars->{"node:file"} . " with insign "
						. $insign . "\n"
					if ($insign !~ /^\s*<\/?[sS]>\s*$/);
			}
		}

   		# Create out-edges
		$globalvars->{'edge:in'} = $globalvars->{'node:id'};
		foreach my $onode (@$outnodes) {
			my $nodeid = $nodes2id->{$outprefix .  $onode};
			if (defined($nodeid)) {
				$globalvars->{'edge:out'} = $nodeid;
				$edges .= DTAG::Graph::create_R_table_row($edgeattributes, $aedge, $globalvars, 'edge:');
				++$nedges;
			} else {
				my $outsign = signature($outgraph, $outnodes, "_input");
				print "Undefined node " . $outprefix . $onode . " in "
					. $aedge->string() . " in " .  $globalvars->{"node:file"} . " with outsign "
						. $outsign . "\n"
					if ($outsign !~ /^<\/?[sS]>$/);
			}
		}

		# Create node
		if ($nedges > 0) {
			$nodes .= DTAG::Graph::create_R_table_row(
				$nodeattributes, $aedge, $globalvars, 'node:');
			++$nodecount;
		}
	}

	# Return
	return ($nodes, $edges, $nodecount, $nodeattributes, $edgeattributes);
}

sub add_na_columns {
    my $table = shift;
    my $n = shift || 0;
	return $table if ($n == 0 || length($table) == 0);
    my $columns = "\tNA" x $n;
    $table =~ s/$/$columns/g;
    return $table;
}

