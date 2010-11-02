sub cmd_save_atag {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Update tag file name
	$graph->file($file) if ($file);
	$file = $graph->file();

	# Open tag file
	open("XML", "> $file") 
		|| return error("cannot open atag-file for writing: $file");

	# Print XML file
	print XML
		$graph->write_atag();

	# Close file
	close("XML");
	print "saved atag-file $file\n" if (! $self->quiet());

	# Mark graph as being unmodified
	$graph->mtime(undef);

	# Return
	return 1;
}

