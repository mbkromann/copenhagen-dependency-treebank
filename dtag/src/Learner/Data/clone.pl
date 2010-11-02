# $self->clone() = $clone: clone data set

sub clone {
	my $self = shift;

	# Create clone
	my $clone = $self->new();

	# Set outcomes in clone
	$clone->outcomes($self->outcomes());
	$clone->data($self->data());

	# Return clone
	return $clone;
}

