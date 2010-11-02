=item $graph->format($var, $regexp) 

Set variable formatting for variable $var to filtering by regular expression $regexp. 

=cut

sub format {
	my $self = shift;
	my $var = shift;
	my $regexp = shift;

	# Process format specification if variable exists
	if (exists $self->{'vars'}{$var}) {
		if ($regexp) {
			# Add new formatting for $var
			$self->{'format'}{$var} = $regexp;
		} else {
			# Delete formatting for $var
			delete $self->{'format'}{$var};
		}
	} else {
		return DTAG::Interpreter::error("Variable $var does not exist!");
	}
}
