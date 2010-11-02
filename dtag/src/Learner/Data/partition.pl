# $self->partition($class) = [$inside, $outside]

sub partition {
	my $self = shift;
	my $hierarchy = shift;
	my $class = shift;

	# Create new data sets 
	my $inside  = $self->clone();
	my $outside = $self->clone();
	my $data = $self->data(); 
	my $dataIn  = $inside ->data([]);
	my $dataOut = $outside->data([]);

	# Partition data 
	foreach my $o (@$data) {
		if ($hierarchy->isa($o, $class)) {
			push @$dataIn, $o;
		} else {
			push @$dataOut, $o;
		}
	}

	# Return list of new data sets
	return [$inside, $outside];
}
