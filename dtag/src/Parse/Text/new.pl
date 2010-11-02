=item Text->new() = $text

Create new Text object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = [];

	# Specify class for new object
	bless ($self, $class);
	$self->inputs({});

	# Return
	return $self;
}

