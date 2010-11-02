=item Edge->new() = $edge

Create new edge $edge.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self: 0=in 1=out 2=type 3=cost 4=tags 5=style
	my $self = [ @_ ];

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	

