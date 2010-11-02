=item $graph->file($file) = $file

Get/set file associated with graph.

=cut

sub file {
	my $self = shift;
		
	# Beautify file name by removing initial "./"
	if (@_) {
		my $s = shift;
		$s =~ s/^(\.\/)+//g;
		return $self->var('_file', $s);
	}

	# Return
	return $self->var('_file', @_);
}
