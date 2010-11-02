package TNegOp;
@TNegOp::ISA = qw(TypeOp);

# Value of !$x
sub value {
	my $self = shift;
	my $lexicon = shift;
	my $type = shift;

	# Invert result from $x
	return 
		($lexicon->isatype($type, $self->[0])) ? 0 : 1;
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


