=item $graph->include($value) = $value

Get/set include hash $value

=cut

sub include {
	my $self = shift;

	# Write new value
	$self->{'_include'} = shift if (@_);

	# Return value
	return $self->{'_include'};
}
	
