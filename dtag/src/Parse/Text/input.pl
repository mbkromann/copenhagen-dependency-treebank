=item $text->input($stream, $input) = $input

Get/set input $input for stream $stream.

=cut


# $input = [[$time0, $time1, $string], ...]

sub input {
	my $self = shift;
	my $stream = shift;
	return undef if (! defined($stream));

	# Set input
	my $inputs = $self->inputs();
	if (@_) {
		$inputs->{$stream} = shift;
		$self->[$TEXT_TIME1] = undef;
	}

	# Get input
	return $inputs->{$stream};
}
