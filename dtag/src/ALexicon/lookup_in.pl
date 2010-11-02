sub lookup_in {
	my $self = shift;
	my $in = shift;

	# Lookup word locally
	my $alexes = $self->lookup_hash($in, $self->in(), $self->fin());
	
	# Initialize strings array to ensure words are only seen once
	my $hash = {};
	map {$hash->{$_->string()} = $_}  @$alexes;

	# Lookup word in sublexicons
	foreach my $sublex (@{$self->sublexicons()}) {
		my $alexes_sub = $sublex->lookup_in($in);
		foreach my $alexnew (@$alexes_sub) {
			my $alexold = $hash->{$alexnew->string()};
			if ($alexold) {
				# Update entry
				$alexold->pos($alexold->pos() + $alexnew->pos());
				$alexold->neg($alexold->neg() + $alexnew->neg());
			} else {
				# Create new entry
				$hash->{$alexnew->string()} = $alexnew;
			}
		}
	}

	# Return
	return [ values(%$hash) ];
}

