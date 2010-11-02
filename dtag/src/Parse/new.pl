=item Parse->new() = $parse

Create new Parse object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = {
	};

	# Specify class for new object
	bless ($self, $class);

	# Initialize
	$self->parseops([]);
	$self->open_lexemes([]);

	# Return
	return $self;
}

