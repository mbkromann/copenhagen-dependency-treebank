sub cframe {
	my $self = shift;
	my $node = shift;
	my $N = $self->node($node);

	# Return cframe for node
    return join("", sort(
		map {ucfirst(lc($_->type()))}
			(grep {$self->is_complement($_)}
				@{$N->out()})));
}
