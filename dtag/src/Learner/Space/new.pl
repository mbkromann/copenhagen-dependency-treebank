# Create new Space object: Space->new($super, $box, $data)
sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Read input parameters
	my $box = shift;
	my $super = shift;
	my $data = shift;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Save parameters
	$self->box($box);
	$self->super($super) if ($super);
	$self->data($data) if ($data);

	# Save count if $super is undefined
	total(scalar(@$data)) if (! defined($super));

	# Set parameters to default values
	$self->subspaces([]);
	$self->weight(1);
	$self->phat(1);
	$self->moved(1);
	$self->pphat(1);
	$self->pweight(1);
	$self->prphat(0);
	$self->prweight(0);

	# Return new object
	return $self;
}

