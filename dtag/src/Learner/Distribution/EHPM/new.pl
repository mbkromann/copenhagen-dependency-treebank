# EHPM->new($hierarchy, $prior, $smoothing)

sub new {
	my $proto = shift;
	my $hierarchy = shift;
	my $prior = shift || sub { 1 };
	my $smoothing = shift;
	my $class = ref($proto) || $proto;

	# Create new object and bless it into new class
	my $self = {}; 
	bless ($self, $class);

	# Initialize object
	$self->hierarchy($hierarchy);
	$self->prior($prior);
	$self->smoothing(defined($smoothing) ? $smoothing : 0);
	$self->cover([DTAG::Learner::Partition->new()]);

	# Initialize 
	# Return new object
	return $self;
}

