sub print_graph {
	my $graph = shift;
	my $id = shift;
	my $index = shift;
	
	return sprintf '%sG%-3d file=%s (%s) %s' . "\n" . '      %s' . "\n",
		($index - 1 == ($id || 0) ? '*' : ' '),
		$index, 
		($graph->file() || '*untitled*'),
		$graph->id(),
		($graph->mtime() ? 'modified ' : 'unmodified'),
		'"' . $graph->text(' ', 60) . '"';
}

