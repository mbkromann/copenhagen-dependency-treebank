sub new_sublexicon {
	my $self = shift;

	my $sublexicon = DTAG::ALexicon->new();
	$sublexicon->var('regexps', $self->var('regexps'));
	push @{$self->sublexicons()}, $sublexicon;
	return $sublexicon;
}
	
