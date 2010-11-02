sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Initialize object
	$self->dimension(shift || 2);
	$self->branching(shift || 2);
	$self->nmax(100);

	# Return new object
	return $self;
}

