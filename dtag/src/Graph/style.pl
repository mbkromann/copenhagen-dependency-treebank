=item $graph->style($default, $name) = $style

Return style $style with style name $name, using $default to find the
default values of styles. 

=cut

sub style {
	my $self = shift;
	my $default = shift;
	my $s = shift;
	my $style = $self->{'styles'} ? $self->{'styles'}{$s} : undef;
	return $style || $default->{'styles'}{$s};
}
