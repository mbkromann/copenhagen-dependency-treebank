package FillOp;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Arguments
	my $type = shift;
	my $srcpath = shift;
	my $govpath = shift;

	# Create new object
	my $self = [$type, $srcpath, $govpath];
	bless($self, $class);
	return $self;
}
