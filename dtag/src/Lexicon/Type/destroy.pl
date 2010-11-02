# type->new($lexicon): Create new type in lexicon $lexicon

sub destroy {
	my $self = shift;

	# Delete all values in $self
	foreach my $key (keys %$self) {
		delete $self->{$key};
	}
}

