sub cmd_load {
	my $self = shift;
	my $graph = shift;
	my $ftype = shift;
	my $fname = shift || "";
	my $optionstr = shift || "";
	$fname =~ s/~/$ENV{HOME}/g;

	# Process options: permitted options {multi=0/1 (create new graph,
	# add to current graph)}
	my $multi = 0;
	$multi = 1 if ($optionstr =~ /-multi/);

    # Open internal graph if $file is an internal graph reference
    if ($fname =~ /^[GA]\[([0-9]+)\]$/) {
        my @graphs = @{$self->{'graphs'}};
        for (my $g = 0; $g < scalar(@graphs); ++$g) {
            if ($graphs[$g]->id() eq $fname) {
				$self->goto_graph($g);
                return 1;
            }
        }
    }

 	# Guess file type
	if (! $ftype) {
		# Default file type
		$ftype = '-tag';

		# Guess file type from extension
		$ftype = '-atag' if ($fname =~ /\.atag$/);
		$ftype = '-key' if ($fname =~ /\.key$/);
		$ftype = '-fix' if ($fname =~ /\.fix$/);
		$ftype = '-eye' if ($fname =~ /\.eye$/);
		$ftype = '-lex' if ($fname =~ /\.lex$/);
		$ftype = '-match' if ($fname =~ /\.match$/);
		$ftype = '-tiger' if ($fname =~ /\.xml$/);
		$ftype = '-malt' if ($fname =~ /\.malt$/);
		$ftype = '-conll' if ($fname =~ /\.conll$/);
	}

	# Load file
	$self->cmd_load_tag($graph, $fname, $multi) if ($ftype eq '-tag');
	$self->cmd_load_atag($graph, $fname) if ($ftype eq '-atag');
	$self->cmd_load_key($graph, $fname, $multi) if ($ftype eq '-key');
	$self->cmd_load_eye($graph, $fname, $multi) if ($ftype eq '-eye');
	$self->cmd_load_fix($graph, $fname, $multi) if ($ftype eq '-fix');
	$self->cmd_load_tiger($graph, $fname) if ($ftype eq '-tiger');
	$self->cmd_load_malt($graph, $fname) if ($ftype eq '-malt');
	$self->cmd_load_emalt($graph, $fname) if ($ftype eq '-emalt');
	$self->cmd_load_conll($graph, $fname) if ($ftype eq '-conll');
	$self->cmd_load_lex($graph, $fname) if ($ftype eq '-lex');
	$self->cmd_load_matches($fname) if ($ftype eq '-match');

	# Return with success
	return 1;
}

