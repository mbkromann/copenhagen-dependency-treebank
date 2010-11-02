sub source {
	my $self = shift;
	my $n = shift;
	my $node = $self->node($n);
	
	return (defined $node ? $node->var('_source') : undef) 
		|| ($self->file() . ":$n");
}
