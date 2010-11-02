sub mlog_likelihood {
	my $self = shift;
	my $data = shift;
	my $mlogL = 0;

	# Process data
	foreach my $d (@{$data->data()}) {
		$mlogL -= $self->logf($data->outcomes()->[$d]);
	}

	# Return
	return $mlogL;
}
