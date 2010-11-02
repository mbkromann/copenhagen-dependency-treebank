# $cover = [$class, [$cover1, ..., $coverN]]

sub cover {
	my $self = shift;
	$self->{'cover'} = shift if (@_);
	return $self->{'cover'};
}
