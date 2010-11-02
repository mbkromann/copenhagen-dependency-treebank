sub cmd_gedit {
	my $self = shift;
	my $graph = shift;
	my $lineno = shift || 0;

	my $file = $graph->file();
	$graph->var("gedit", 1);
	system("gedit +" . (++$lineno) . " $file &");
}
