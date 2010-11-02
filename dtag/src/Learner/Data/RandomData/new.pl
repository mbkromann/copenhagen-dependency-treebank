sub new {
	# Call super constructor 
	my $proto = shift;
	my $new = DTAG::Learner::Data::new($proto);

	# Generate random outcomes
	$new->generate(@_);
	
	# Return new data set
	return $new;
}
