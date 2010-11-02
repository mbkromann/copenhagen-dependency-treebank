=item $node->svar($var, $value) = $value

Get/set value $value associated with variable $var at $node. Returns
"" instead of undef.

=cut

sub svar {
	my $self = shift;
	my $var = shift;

	# Write new value
	$self->{$var} = shift if (@_);

	# Return value
	my $val = $self->{$var};
	return defined($val) ? $val : "";
}
	
