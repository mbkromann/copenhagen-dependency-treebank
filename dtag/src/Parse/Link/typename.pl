=item $link->typename($typename) = $typename

Get/set typename of link.

=cut

sub typename {
	my $self = shift;
	$self->[$LINK_TYPENAME] = shift if (@_);
	return $self->[$LINK_TYPENAME];
}
