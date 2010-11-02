# Example: $I->find_key($graph, $match, $key)

sub find_key {
	# Arguments
	my $self = shift;
	my $graph = shift;
	my $match = shift;
	my $key = shift;

	# Parse $key
	my $string = "";
	my ($node, $n1, $n2, $e);
	while ($key) {
		if ($key =~ s/^\&yield\[\]\((\$\w+(,\$\w+)*)\)//
				|| $key =~ s/^\&yield// ) {
			
		} elsif ($key =~ s/^\&edges\(\$(\w+),\$(\w+)\)//) {
			my $n1 = $match->{'$' . $1};
			my $n2 = $match->{'$' . $2};
			$node = $graph->node($n1);
			$string .= join("|", map {($_->type() || "?")} 
				(grep {$_->out() == $n2} @{$node->in()}));
		} elsif ($key =~ s/^\$(\w+)\[~(\w+)\]//) {
			$node = $graph->node($match->{'$' . $1});
			$string .= ($graph->reformat($self, $2, $node->var($2)))
				if ($node);
		} elsif ($key =~ s/^\$(\w+)\[(\w+)\]//) {
			$node = $graph->node($match->{'$' . $1});
			$string .= ($node->var($2) || "") if ($node);
		} elsif ($key =~ s/^\$(\w+)//) {
			$node = $graph->node($match->{'$' . $1});
			$string .= ($node->var('_input') || "") if ($node);
		} elsif ($key =~ s/^([^\$\&]*)//) {
			$string .= $1;
		} elsif ($key =~ s/^\$\$//) {
			$string .= '$';
		} else {
			$string .= '$';
			$key =~ s/^\$//;
		}
	}

	# Return string
	return $string;
}
