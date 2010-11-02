sub f {
	my $self = shift;
	my $x = shift;
	my $distribution = shift;

	# Find prior value of $x
	my $priorf = &{$distribution->prior()}($x);
	my $total = $distribution->total();
	my $smoothing = $distribution->smoothing();

	# Compute smoothed value
	my $prior_mass = $self->prior_mass();
	if ($prior_mass <= 0) {
		print ("-" x 80);
		print "\nERROR: prior mass $prior_mass non-positive in partition";
		print $distribution->hierarchy()->print_box($self->space_box());
		print "in EHPM ";
		print $distribution->print();
		print "\n" . ("-" x 80) .  "\n";
	}
	print "ERROR: total $total non-positive\n" if ($total <= 0);

	my $hpm = ($self->count() / ($total || 1)) 
		* ($priorf / ($self->prior_mass() || 1));
	my $epsilon = $smoothing / ($total + $smoothing);
	my $ehpm = (1 - $epsilon) * $hpm + $epsilon * $priorf;
	
	# Return smoothed value
	return $ehpm;
}
