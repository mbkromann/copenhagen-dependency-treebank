sub insert {
	my $self = shift;
	my $alex = shift;

	# Insert alex into lexicon
	my $id = $self->new_alex_id();
	my $alexlist = $self->alex();
	$alexlist->[$id] = $alex;

	# Insert alex into in and out pattern hash tables
	$self->insert_pattern($self->in(), $alex->in(), $id, $self->fin());
	$self->insert_pattern($self->out(), $alex->out(), $id, $self->fout());

	# Return
	return $self;
}

