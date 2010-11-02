=item $graph->reformat($interpreter, $var, $value, $graph, $node) = $filtered

Return filtered value $filtered for variable $var with value $value,
using $interpreter to provide default filters. 

=cut

sub reformat {
	my $self = shift;
	my $interpreter = shift;
	my $var = shift;
	my $str = shift;
	my $graph = shift;
	my $node = shift;
	$str = "" if (! defined($str));

	# Reformat string according to specification in $self->{'format'}
	my $code = ($self->layout($interpreter, 'var') || {})->{$var};
	if ($code) {
		return &$code($str, $graph, $node, $var);
	}

	# Return formatted string
	return $str;
}
