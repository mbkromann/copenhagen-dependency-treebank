package CompOp;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Arguments
	my $type = shift;
	my $hash = { };
	while (@_) {
		$hash->{shift} = shift;
	}

	# Create new object
	my $self = [$type, $hash];
	bless($self, $class);
	return $self;
}

sub type {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0];
}

sub comps {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1];
}

