sub split_params {
	my $self = shift;
	my $sbox = shift;
	my $sdata = shift;

	# Calculate parent properties
	my $phat = $self->rphat();
	my $weight = $self->rweight();
	my $count = scalar(@{$self->rdata()}) + $smooth;

	# Return if $phat is zero
	return [0, 0, 0, 0, 0]
		if (abs($phat) < 1e-250);

	# Calculate prior probability of subspaces
	my @superiors = map {$_->box()}
		(@{$self->subspaces()}, @{$self->superiors()});
	my $sphat = @superiors
		? $self->compute_phat(['-', $sbox, @superiors])
		: $self->compute_phat($sbox);
	my $rphat = $phat - $sphat;

	# Validity check
	$sphat = 0 if ($sphat <= 0);
	$rphat = 0 if ($rphat <= 0);

	# Calculate counts in the two subspaces
	my $scount = scalar(@$sdata) + $smooth * $sphat / $phat;
	my $rcount = $count - $scount;
	my $mass = $phat * $weight;
	my $smass = $scount / $count * $mass;
	my $rmass = $rcount / $count * $mass;
	my $sweight = ($sphat > 0) ? $smass / $sphat : 0;
	my $rweight = ($rphat > 0) ? $rmass / $rphat : 0;
	my $moved = $smass - $weight * $sphat;

	# Return parameters
	return [$moved, $sweight, $rweight, $sphat, $rphat];
}
