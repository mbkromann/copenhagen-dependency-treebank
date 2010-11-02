package TMinusOp;
@TMinusOp::ISA = qw(TypeOp);

# Value of $x-$y
sub value {
	my $self = shift;
	my $lexicon = shift;
	my $type = shift;

	# Return 0 if $x is 0
	if (! $lexicon->isatype($type, $self->[0])) {
		return 0;
	}
	
	# Return 0 if $y is 1
	if ($lexicon->isatype($type, $self->[1])) {
		return 0;
	} 

	# Else return 1
	return 1;
}
