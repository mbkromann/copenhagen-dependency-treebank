=item $parse->parserank($i) = $rank

Return rank of parsing operation $i.

=cut

sub parserank {
	my $self = shift;
	my $i = shift;
	return $self->parseops()->[$i][1];
}
