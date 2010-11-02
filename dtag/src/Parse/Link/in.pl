=item $link->in($in) = $in

Get/set in-segment of link.

=cut

sub in {
	my $self = shift;
	$self->[$LINK_IN] = shift if (@_);
	return $self->[$LINK_IN];
}
