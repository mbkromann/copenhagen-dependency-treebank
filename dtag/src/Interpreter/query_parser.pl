sub query_parser {
	my $self = shift;
	$query_parser = new Parse::RecDescent ($query_grammar)
		if (! $query_parser);
	
	return $query_parser;
}
