=item $graph->ddominates($super, $node) = $boolean

Return true if $super dominates or equals $node in the deep tree.

=cut

sub ddominates {
	my $self = shift;
	my $super = shift;
	my $node = shift;

	# Succeed if $super equals $node
	return 1 if ($super == $node);
	
	# Succeed if $super ddominates governor of $node, fail if no
	# governor exists
	my $gov = $self->governor($node);
	return $gov ? $self->ddominates($super, $gov) : 0;
}
