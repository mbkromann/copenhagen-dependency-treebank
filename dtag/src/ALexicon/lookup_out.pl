sub lookup_out {
	my $self = shift;
	my $out = shift;
	my $hash = shift || {};


	# Lookup word locally
	my $alexes = $self->lookup_hash($out, $self->out(), $self->fout());
	
	# Initialize strings array to ensure words are only seen once
	map {$hash->{$_->string()} = $_}  @$alexes;

	# Lookup word in sublexicons
	foreach my $sublex (@{$self->sublexicons()}) {
		my $alexes_sub = $sublex->lookup_out($out);
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

