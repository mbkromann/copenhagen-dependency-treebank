=item $parse->pop_op() = $top

Return top object on stack. ???

=cut

sub pop_op {
	my $self = shift;
	$self->stackhash(undef);
	return pop(@{$self->stack()});
}
