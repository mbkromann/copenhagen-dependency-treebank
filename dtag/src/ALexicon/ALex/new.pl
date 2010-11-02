=item ADictionary->new() = $adict

Create new ADictionary object.

=cut

# out=0 in=1 type=2 pos=3 neg=4 id=5 allpos=6 allneg=7

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self: 
	my $self = [ ];		

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	

