=item $graph->exclude($value) = $value

Get/set exclude hash $value

=cut

sub exclude {
	my $self = shift;

	# Write new value
	$self->{'_exclude'} = shift if (@_);

	# Return value
	return $self->{'_exclude'};
}
	
