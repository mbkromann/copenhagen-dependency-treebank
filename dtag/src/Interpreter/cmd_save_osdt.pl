sub cmd_save_osdt {
	my $self = shift;
	my $graph = shift;
	my $file = shift || "";

	# Update tag file name
	$graph->file($file) if ($file);
	$file = $graph->file();

	# Check whether file name exists
    if (! $file) {
		error("cannot save: no name specified for file")
			if ($graph->mtime());
		return 1;
	}
						
	# Open tag file
	Node->use_color(0);
	open(XML, "> $file") 
		|| return error("cannot open osdt-file for writing: $file");
	print XML $graph->print_osdt();
	close(XML);
	print "saved osdt-file $file\n" if (! $self->quiet());

	# Mark graph as being unmodified
	$graph->mtime(undef);

	# Return
	return 1;
}

