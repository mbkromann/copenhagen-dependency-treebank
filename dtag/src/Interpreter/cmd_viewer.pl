sub cmd_viewer {
	my $self = shift;
	my $graph = shift;
	my $option = shift || "";

	# Specify new follow file
	++$viewer;
	my $fpsfile = "/tmp/dtag-$$-$viewer.ps";
	if ($graph->var("example") || $option eq "-e" || $option eq "-example") {
		$self->var("exfpsfile", $fpsfile);
		$graph = $self->var("examplegraph") || DTAG::Graph->new($self)
			if (! $graph->var("example"));
	} else {
		$self->fpsfile($fpsfile);
	}

	# Record fpsfile as a viewed file
	$self->{'viewfiles'} = {} 
		if (! defined($self->{'viewfiles'}));
	$self->{'viewfiles'}->{$fpsfile} = 1;

	# Update graph and viewer
	$self->{'viewer'} = 1;
	$graph->fpsfile($fpsfile);
	$self->cmd_return($graph);

	# Call viewer on $fpsfile
	my $viewcmd = "" . ($self->var('options')->{'viewer'} || 'gv $file &');
	$viewcmd =~ s/\$file/$fpsfile/g;
	print "opening viewer with \"$viewcmd\"\n" if ($self->debug());
	system($viewcmd);

	# Set follow file for current graph
	return 1;
}
