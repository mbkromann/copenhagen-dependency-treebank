sub cmd_viewer {
	my $self = shift;
	my $graph = shift;
	my $option = shift || "";
	#print "option: $option\n";

	# Specify new follow file
	$self->{'viewer'} = 1;
	++$viewer;
	my $fpsfile = "/tmp/dtag-$$-$viewer.ps";
	my $fpsfiles = {"" => $fpsfile};
	if ($graph->var("example") || $option eq "-e" || $option eq "-example") {
		$self->var("exfpsfile", $fpsfile);
		$graph = $self->var("examplegraph") || DTAG::Graph->new($self)
			if (! $graph->var("example"));
	} elsif ($option =~ /^-a/ && $graph->is_alignment()) {
		# Add fpsfiles for subgraphs
		delete $fpsfiles->{""};
		$fpsfiles->{":"} = $fpsfile;
		foreach my $key (sort(keys(%{($graph->graphs())}))) {
			my $f = "/tmp/dtag-$$-$viewer-$key.ps";
			my $subgraph = $graph->graph($key);
			$subgraph->fpsfile($f);
			$self->fpsfile($key, $f);
			$fpsfiles->{":" . $key} = $f;
			#print "Subgraph: $subgraph $f\n";
			$self->cmd_return($subgraph);
		}
	}

	# Add fpsfile
	$self->fpsfile("", $fpsfile);
	$graph->fpsfile($fpsfile);

	# Record fpsfile as a viewed file
	$self->{'viewfiles'} = {} 
		if (! defined($self->{'viewfiles'}));
	map {$self->{'viewfiles'}->{$fpsfiles->{$_}} = 1} keys(%$fpsfiles);

	# Update graph and viewer
	$self->cmd_return($graph);

	# Call viewer on $fpsfile
	foreach my $key (sort(keys(%$fpsfiles))) {
		my $f = $fpsfiles->{$key};
		my $viewcmd = "" . ($self->option('viewer' . $key)
			|| $self->option('viewer') 
			|| 'gv $file &');
		$viewcmd =~ s/\$file/$f/g;
		print "opening viewer with \"$viewcmd\"\n" if ($self->debug());
		system($viewcmd);
	}

	# Return
	return 1;
}
