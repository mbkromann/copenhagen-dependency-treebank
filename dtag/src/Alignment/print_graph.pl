sub print_graph {
	my $self = shift;
	my $id = shift;
	my $index = shift;
	
	my $s = sprintf '%sA%-3d file=%s (%s) %s' . "\n",
		($index - 1 == ($id || 0) ? '*' : ' '),
		$index, 
		($self->file() || '*untitled*'),
		$self->id(),
		($self->mtime() ? 'modified ' : 'unmodified');
	
	foreach my $key (sort(keys(%{$self->{'graphs'}}))) {
		my $graph = $self->{'graphs'}{$key};
		$s .= "      $key [" . ($graph->file() || ""). "]: \""
			. $graph->text(' ', 30) . "\"\n";
	}

	return $s;
}

