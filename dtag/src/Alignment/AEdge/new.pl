=item Edge->new() = $edge

Create new edge $edge.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self: 0=inkey 1=in 2=outkey 3=out 4=type 5=tags 6=creator 7=alex 8=format
	my $self = [ @_ ];

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	

