sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Initialize
	$self->plane([]);
	$self->space([]);

	# Return new object
	return $self;
}

