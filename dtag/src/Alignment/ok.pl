sub ok {
	my $self = shift;

	# Return false (0) if no learner is associated with alignment
	return 0 if (! $self->alexicon());

	# Pass on ok to learner
	$self->alexicon()->ok($self);

	# Auto-adjust offsets
	$self->auto_offset();

	# Return true: ok operation succeeded
	return 1;
}
