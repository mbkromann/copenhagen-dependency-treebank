=item Node->new() = $node

Create new node.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = {
		'_in' => [],
		'_out' => [],
		'_lexemes' => [],
		'_active' => [],
		'_cost' => 0,
		'_extracted' => [],
		'_type' => 'W' };

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	

