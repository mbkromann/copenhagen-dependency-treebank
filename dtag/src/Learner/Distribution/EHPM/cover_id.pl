sub cover_id {
	my $self = shift;
	my $cover = shift || $self->cover();

	return join(" ", 
		map {$self->hierarchy()->print_box($_->space_box())}
			@$cover);
}
