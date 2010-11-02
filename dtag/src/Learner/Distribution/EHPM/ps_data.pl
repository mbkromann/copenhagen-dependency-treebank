sub ps_data {
	my $self = shift;

	# Plot PSMath data
	my $s = "% Plot data\n";
	foreach my $p (@{$self->cover()}) {
		my $data = $p->data();
		foreach my $d (@{$data->data()}) {
			my $point = $data->outcome($d);
			$s .= ($point->[0] * 100) . " " 
				. ($point->[1] * 100) . " dot\n";
		}
	}

	# Return string
	return $s . "\n0 0 100 100 box stroke\n\n";
}
