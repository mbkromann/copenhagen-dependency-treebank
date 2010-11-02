=item $parse->push_op($op) = $parse

Push new operation onto stack.

=cut

sub push_op {
	my $self = shift;
	push @{$self->stack()}, shift; 
	$self->stackhash(undef);
	return $self;
}
