sub split {
	# Arguments
	my $self = shift;
	my $dim = shift;
	my $subtype = shift;

	# Compute boxes
	my $box = $self->box();
	my $sbox = [@$box];
	$sbox->[$dim] = $subtype;

	# Divide data between subspace and its parent
	my ($sdata, $rdata) = @{$self->split_data($self->rdata(), $dim, $subtype)};

	# Retrieve parameters
	my @args = @_;
	if (scalar(@args) != 5) {
		@args = @{$self->split_params($sbox, $sdata)};
	}
	my ($moved, $sweight, $rweight, $sphat, $rphat) = @args;

	# Create new subspace 
	my $subspace = Space->new($sbox, $self); 
	$subspace->super($self);
	push @{$self->subspaces()}, $subspace;

	# Set parameters in subspace
	$subspace->data($sdata);
	$subspace->phat($sphat);
	$subspace->weight($sweight);
	$subspace->moved($moved);
	$subspace->pweight($self->rweight());
	$subspace->pphat($self->rphat());
	$subspace->prweight($rweight);
	$subspace->prphat($rphat);
	$subspace->splitdim($dim);
	$subspace->splittype($subtype);

	# Set parameters in parent space
	$self->rdata($rdata);
	$self->rphat($rphat);
	$self->rweight($rweight);

	# Return subspace
	return $subspace;
}

