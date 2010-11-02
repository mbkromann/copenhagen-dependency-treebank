sub mlog_likelihood {
	my $self = shift;
	my $cover = shift || $self->cover();

	# Compute minus-log likelihood of all partitions in cover
	my $mlogL = 0;
	foreach my $partition (@$cover) {
		# Compute minus-log probability of each observation
		my $data = $partition->data();
		foreach my $d (@{$data->data()}) {
			$mlogL += - log($partition->f($data, $self));
		}
	}
}
