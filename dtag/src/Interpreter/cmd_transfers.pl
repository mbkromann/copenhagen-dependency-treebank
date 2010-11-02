# cmd_transfers($self, $graph, $clear, $savedir, $files): extract 
# transfer rules from the files matching $files; save the current
# transfer lexicon in $savedir; and possibly clear the current transfer
# lexicon

sub cmd_transfers {
	# Read input arguments
	my ($self, $graph, $clear, $savedir, $filenames) = @_;

	# Clear current transfer lexicon
	$self->{'translex'} = {} if ($clear);

	# Check that $graph is an alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("current graph is not an alignment");
		return 1;
	}

	# Process files in $filenames
	my @files = split(/\s+/, $filenames);
	if (@files) {
		error("transfers: multiple filenames not supported yet");
	} else {
		# Process current graph
		$graph->extract_translex($self);
	}

	# Save transfer lexicon if $savedir specified
	if ($savedir) {
		# Save...
		error("transfers: saving not supported yet");
	}

	# Return
	return 1;
}
