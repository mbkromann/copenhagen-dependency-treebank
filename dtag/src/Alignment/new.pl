=item Alignment->new() = $align

Create new Alignment object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $interpreter = shift;

	# Create self: 
	my $self = { 
		'id' => ++$DTAG::Interpreter::graphid,
		'compounds' => {},
		'interpreter' => $interpreter
	};

	# Specify class for new object
	bless ($self, $class);
	$self->clear();

	# Return
	return $self;
}	

