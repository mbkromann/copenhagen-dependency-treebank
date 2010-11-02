=item Segment->new() = $segment

Create new segment.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = []; 

	# Specify class for new object
	bless ($self, $class);

	# Initialize object
	$self->lexemes([]);
	$self->active([]);
	$self->span([]);

	# Return
	return $self;
}

