sub cmd_replace {
	my ($self, $graph, $replace) = @_;

	# Replace at current position if replacement is given
	my $filelist = $self->{'replace_files'};
	my $matchlist = $self->{'replace_matches'};
	my $file = $filelist->[0];
	my $match = $matchlist->[0];
	my $relhash = $self->{'replace_hash'};

	# Check arguments
	if (! defined($filelist)) {
		error("autoreplace not active");
		return 1;
	}

	if ($replace) {
		if ($file && defined($match) && $graph &&
				($graph->file() || "") eq $file || $file =~ /^\[/) {
			# Find matching edge
			my $dep = $match->{'$dep'};
			my $gov = $match->{'$gov'};
			my $depnode = $graph->node($dep);
			my @edges = grep {$_->out() == $gov && $relhash->{$_->type()}} 
				@{$depnode->in()};
			my $edge = $edges[0];

			# Delete edge
			$graph->edge_del($edge) if ($edge);

			# Add new edge
			$self->cmd_edge($graph, $dep - $graph->offset(),
				$replace, $gov - $graph->offset());
			print "edit: $dep " . $replace . " $gov\n";
		}
	}

	# Advance to next position and show graph
	shift(@$matchlist);
	if (! @$matchlist) {
		# Save previous file
		if ($file && ($graph->file() || "") eq $file) {
			$self->cmd_save($graph);
		}

		# Advance to next graph and return if undefined
		shift(@$filelist);
		$file = $filelist->[0];
		if (! $file) {
			warning("replace: no more matches\n");
		    $self->{'replace_files'} = undef;
			my $gfile = $graph->file() || "";
			return 1;
		}
		$matchlist = $self->{'replace_matches'} 
			= [@{$self->{'matches'}{$file}}];
		# Load new graph
		if (! ($graph && ($graph->file() || "") eq $file)) {
	        $self->cmd_load($graph, undef, $file);
	        $graph = $self->graph();
			print "=== $file ===\n";
	    }
	}

	# Load first match
	$match = $matchlist->[0];
	$self->{'replace_match'} = {$graph => [$match]};
	my $dep = $match->{'$dep'};
	my $gov = $match->{'$gov'};
	my $min = min($dep, $gov);
	my $depnode = $graph->node($dep);
	my @edges = grep {$_->out() == $gov && $relhash->{$_->type()}} 
		@{$depnode->in()};
	my $edge = $edges[0];

	# Goto this position
	$self->cmd_show($graph, $min - $self->var('goto_context'));
	print "next: $dep " . $edge->type() . " $gov\n";

	return 1;
}
