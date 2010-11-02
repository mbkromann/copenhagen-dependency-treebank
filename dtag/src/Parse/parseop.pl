=item $parse->parseop($i) = $parseop

Return the $i'th parsing operation.

=cut

sub parseop {
	my $self = shift;
	my $i = shift;
	return $self->parseops()->[$i][0];
}
