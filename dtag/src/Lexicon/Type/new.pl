# type->new($name, $super1, ..., $superN): 
# 		Create new type with name $name and super types $super1,...,$superN

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = { '_super' => [] };

	# Specify class for new object
	bless ($self, $class);

	# Initialize name and new parents
	$self->set_name(shift) if (@_);
	$self->set_super(@_) if (@_);
	
	# Return
	return $self;
}	

