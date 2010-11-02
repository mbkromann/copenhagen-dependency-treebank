=item $link->out($out) = $out

Get/set out-segment of link.

=cut

sub out {
	my $self = shift;
	$self->[$LINK_OUT] = shift if (@_);
	return $self->[$LINK_OUT];
}
