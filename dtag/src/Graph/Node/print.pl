=item $node->print() = $string

Return string representation of $node (used for debugging only).

=cut

sub print {
	my $self = shift;
	return "node("
		. "input=" . $self->input()
		. " segment=" . $self->segment()
		. " position=" . $self->position()
		. " lexemes=[" . join(",", @{$self->lexemes()}) . "]"
		. " active=[" . join(",", @{$self->active()}) . "]"
		. " selected=" . $self->selected()
		. " cost=" . $self->cost()
		. " in=[" . join(",", @{$self->in()}) . "]"
		. " out=[" . join(",", @{$self->out()}) . "]"
		. " extracted=[" . join(",", @{$self->extracted()}) . "]"
		. " layout=" . $self->layout()
		. ")";
}
