sub compute_prior_mass {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift;

	# Compute prior mass
	$self->prior_mass($distribution->hierarchy()->pbox_diff(
		$distribution->prior(), $self->space_box(), 
		map {$_->space_box()} @$precover));

	# Return prior mass
	return $self->prior_mass();
}
