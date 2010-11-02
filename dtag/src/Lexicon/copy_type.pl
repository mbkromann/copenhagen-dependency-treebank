# $copy = $lexicon->copy_type($types, $source)

sub copy_type {
	my $self = shift;
	my $types = shift;
	my $source = shift;

	# Convert singular type into array
	$types = [ $types ]
		if (! UNIVERSAL::isa($types, 'ARRAY'));

	# Create empty copy
	my $copy = Type->new();

	# Find variables used in type
	my $vars = { '_super' => 1, '_name' => 1, '_roots' => 1 };
	foreach my $t (@$types) {
		$self->vars($t, $vars);
	}

	# Copy variable values into copy
	foreach my $v (keys(%$vars)) {
		my ($inh, $value) = $self->xvar($types, $v);
		$copy->var($v, $self->copy_obj($value, $source)) if (defined($value));
	}

	# Return copy
	return $copy;
}


