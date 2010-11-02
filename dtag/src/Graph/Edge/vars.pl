=item $edge->vars($vars) = $vars

Get/set variable string for edge, used for storing variable-value
pairs. 

=cut

sub vars {
	my $self = shift;
	$self->[4] = shift if (@_);
	return $self->[4] || "§";
}
