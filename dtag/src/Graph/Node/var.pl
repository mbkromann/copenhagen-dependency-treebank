=item $node->var($var, $value) = $value

Get/set value $value associated with variable $var at $node.

=cut

sub var {
	my $self = shift;
	my $var = shift;

	# Write new value
	$self->{$var} = shift if (@_);

	# Return value
	return $self->{$var};
}
	
