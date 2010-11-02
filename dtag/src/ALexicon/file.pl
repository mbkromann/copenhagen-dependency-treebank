=item $alignment->file($file) = $file

Get/set file associated with alignment.

=cut

sub file {
	my $self = shift;
	return $self->var('_file', @_);
}
