=item $graph->print() = $string

Return simple string representation for graph (used for debugging
only).

=cut

sub print {
	my $self = shift;

	return "graph(" 
		. "nodes=[" . join(",", @{$self->nodes()}) . "]"
		. " input="  . $self->input()
		. " position=" . $self->position()
		. " boundaries=[" . join(",", @{$self->boundaries()}) . "]"
		. " vars=[" . join(",", 
			map {"$_=" . $self->vars()->{$_}} sort(keys(%{$self->vars()}))) 
				. "]"
		. ")";
}
