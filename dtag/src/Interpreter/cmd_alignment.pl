sub cmd_alignment {
	my $self = shift;
	my $fnames = shift;

	# Create new align object
	my $align = DTAG::Alignment->new($self);

	# Load files
	my $fnum = 97;
	foreach my $fname (split(' ', $fnames)) {
		print "alignment file " . chr($fnum) . ": $fname\n";
		$self->cmd_load($self->graph(), "", $fname);
		$align->add_graph(chr($fnum++), $self->graph());
	}

	# Add alignment to DTAG's list of graphs
	push @{$self->{'graphs'}}, $align;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Update graph
	$self->cmd_return($align);
	return 1;
}
