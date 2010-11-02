=item $text->time1() = $time1

Return ending time of text.

=cut

sub time1 {
	my $self = shift;

	# Find cached value
	my $time1 = $self->[$TEXT_TIME1];
	return $time1 if (defined($time1));

	# Find length of longest input stream
	$time1 = 0;
	foreach my $s (@{$self->streams()}) {
		my $len = length($self->input($s));
		$time1 = $len if ($len > $time1);
	}

	# Return length of longest input stream
	$self->[$TEXT_TIME1] = $time1;
	return $time1;
}
