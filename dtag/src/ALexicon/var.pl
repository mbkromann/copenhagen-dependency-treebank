=item $graph->var($var, $value) = $value

Get/set value $value for variable $var.

=cut

sub var {
	my $self = shift;
	my $var = shift;

	# Write new value
	$self->{$var} = shift if (@_);

	# Return value
	return $self->{$var};
}
	
