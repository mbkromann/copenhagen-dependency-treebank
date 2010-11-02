sub new {
	# Call super constructor 
	my $proto = shift;
	my $new = DTAG::Learner::Data::new($proto);

	# Read arguments
	my $graph = $new->{'graph'} = shift;

	# Add all non-comment nodes as outcomes
	my $outcomes = $new->outcomes([]);
	my $size = $graph->size();
	for (my $i = 0; $i < $size; ++$i) {
		push @$outcomes, $i
			if (! $graph->node($i)->comment());
	}

	# Return new data set
	return $new;
}
