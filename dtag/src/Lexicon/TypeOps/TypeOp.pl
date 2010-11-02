package TypeOp;
use overload 
	'""' => \&print;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $self = [];
	push @$self, @_;
	bless($self, $class);
	return $self;
}

sub print {
	my $self = shift;
	my @args = ();
	foreach my $arg (@$self) {
		if (ref($arg) && $arg->isa("TypeOp")) {
			push @args, "$arg";
		} else {
			push @args, "$arg";
		}
	}
	my $name = lc(ref($self));
	$name =~ s/op$//g;
	return $name . "(" . join(", ", @args) . ")";
}


