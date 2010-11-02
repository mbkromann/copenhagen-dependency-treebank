sub lookup {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;

	# Return local entry, if there is one
	my $alex = $self->lookup_local($out, $type, $in);
	return $alex if ($alex);

	# Return first entry in sublexicon, if there is one
	foreach my $sub (@{$self->sublexicons()}) {
		$alex = $sub->lookup($out, $type, $in);
		return $alex if ($alex);
	}

	# No matching entry found
	return undef;
}



