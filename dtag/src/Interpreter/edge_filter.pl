sub edge_filter {
	my $self = shift;
	my $string = shift;

	my $table = $self->var("edgefilters");
	$self->var("edgefilters", $table = {}) if (! defined($table));

	# Use existing filter, if present
	my $filter = $table->{$string};
	return $filter if (defined($filter));

	# Create new filter
	my $xstring = $string ? " $string " : "  ";
	$filter = $table->{$string} = 
		$self->query_parser()->RelationPattern(\$xstring);
	#print "Defined filter: $filter\n";
	return $filter;
}
