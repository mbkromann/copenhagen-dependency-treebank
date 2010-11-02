sub mlog_likelihood {
	my $self = shift;
	my $partition = shift;

	# Compute minus log likelihood of data in all partitions
	my $mlogL = 0;
	my $data = $partition->data();
	foreach my $d (@{$data->data()}) {
		$mlogL -= log($partition->f($data->outcome($d), $self) || 1e-100);
	}

	# Return minus log likelihood
	return $mlogL;
}
