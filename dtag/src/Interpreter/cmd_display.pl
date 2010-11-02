sub cmd_display {
	my $self = shift;
	my $graph = shift || $self->graph();
	my $followfile = $graph->fpsfile() || $self->fpsfile();
	my $displayfile = shift || $followfile;

	if ( -r $displayfile ) {
		system("cp $displayfile $followfile");
	} else {
		error("Cannot read file: $displayfile\n");
	}
	return 1;
}
