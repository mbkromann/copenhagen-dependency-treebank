#	Create new data object: Data->new() = $data

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# create new object and bless it into new class
	my $self = {'outcomes' => [], 'data' => []}; 
	bless ($self, $class);

	# return new object
	return $self;
}

