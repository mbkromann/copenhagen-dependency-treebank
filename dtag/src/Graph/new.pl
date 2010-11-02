=item Graph->new() = $graph

Create new Graph object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $interpreter = shift;
	my $class = ref($proto) || $proto;


	# Create self: 
	my $self = { 
		'nodes' => [], 
		'boundaries' => [], 
		'vars' => {'id' => undef}, 
		'format' => {},
		'imin' => -1,
		'imax' => -1,
		'id' => ++$DTAG::Interpreter::graphid,
		'lexstream' => {},
		'inalign' => {},
		'interpreter' => $interpreter
	};

	# Specify class for new object
	bless ($self, $class);
	$self->clear();

	# Return
	return $self;
}	

