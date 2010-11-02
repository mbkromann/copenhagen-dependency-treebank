sub add_alex {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;
	my $pos = shift;
	my $neg = shift || 0;

	# Check positive weight
	if ($pos < 0) {
		$neg = - $pos;
		$pos = 0;
	}

	# Lookup alex locally, and create it if necessary
	my $alex = $self->lookup_local($out, $type, $in);
	if (! $alex) {
		# Create alex
		$alex = ALex->new();
		$alex->out($out);
		$alex->type($type);
		$alex->in($in);
		$self->insert($alex);
	} 
	
	# Update weights
	$alex->incpos($pos);
	$alex->incneg($neg);

	# Return alex
	return $alex;
}

