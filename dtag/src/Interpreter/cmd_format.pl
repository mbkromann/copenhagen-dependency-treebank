sub cmd_format {
	my $self = shift;
	my $graph = shift;
	my $var = shift;
	my $regexp = shift;

	# Call corresponding layout command
	$self->cmd_layout($graph, "-var $var $regexp");

	# Return
	return 1;
}
