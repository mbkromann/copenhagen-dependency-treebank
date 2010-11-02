package OrOp;
@OrOp::ISA = qw(CostOp);

sub match_node {
	my $self = shift;
	my $node = shift;

	foreach my $arg (@$self) {
		return 1 if ($arg->match_node($node));
	}
	return 0;
}
