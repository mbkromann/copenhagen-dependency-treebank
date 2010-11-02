sub cmd_inline {
	my $self = shift;
	my $graph = shift;
	my $posr = shift;
	my $inline = shift;

	$self->cmd_comment($graph, $posr, "<!-- <dtag>$inline</dtag> -->");
	return 1;
}
