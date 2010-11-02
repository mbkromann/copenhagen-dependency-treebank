=item $parse->parseop_add($parseop, $rank) = $parse

Add a new parse operation $parseop with rank $rank.

=cut

sub parseop_add {
	my $self = shift;
	my $parseops = $self->parseops();

	# Read parameters
	my $parseop = shift;
	my $rank = shift;
	$rank = $self->parserank(scalar(@$parseops)-1) + 1
		if (! defined($rank));

	# Add parsing operation
	push @$parseops,
		[$parseop, $rank];
	$self->parseops([sort {$a->[1] <=> $b->[1]} @$parseops]);

	# Return 
	return $self;
}
