=item $graph->layout($default, $var) = $layout

Return layout value $layout for variable $var, retrieving the layout
value from $default if it isn't defined by $graph.

=cut

sub layout {
	my $self = shift;
	my $default = shift;
	my $var = shift;
	my $layout = $self->{'layout'} ? $self->{'layout'}{$var} : undef;
	return $layout || $default ->{'layout'}{$var};
}
