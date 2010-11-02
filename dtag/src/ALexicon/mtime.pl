=item $graph->mtime($set) = $mtime

Get/set modification time of graph. If $set is defined, $mtime is set
to the current time.

=cut

sub mtime {
	my $self = shift;
	if (@_) {
		$self->{'mtime'} = shift() ? time() : undef;
	}
	return $self->{'mtime'};
}
