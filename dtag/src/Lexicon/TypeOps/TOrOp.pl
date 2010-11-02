package TOrOp;
@TOrOp::ISA = qw(TypeOp);

# Value of $x|$y
sub value {
	my $self = shift;
	my $lexicon = shift;
	my $type = shift;

	# Return 1 if $x is 1
	return 1 if($lexicon->isatype($type, $self->[0]));
	
	# Return 1 if $y is 1
	return 1 if($lexicon->isatype($type, $self->[1]));

	# Else return 0
	return 0;
}
