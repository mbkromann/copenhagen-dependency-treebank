# Create new learner object

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Return new object
	return $self;
}

