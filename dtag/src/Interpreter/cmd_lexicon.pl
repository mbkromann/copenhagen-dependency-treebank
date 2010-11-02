sub cmd_lexicon {
	my $self = shift;
	my $lexname = shift;

	# Close old lexicon
	my $old = $self->lexicon();
	$lexname = $old->name() 
		if ((! $lexname) && UNIVERSAL::isa($old, 'DTAG::Lexicon'));
	$old->close() if ($old);

	# Change lexicon
	print "Current lexicon is: $lexname\n" if (! $self->quiet());
	my $new = DTAG::Lexicon->new($lexname);
	if ($new) {
		$new->name($lexname);
		$self->lexicon($new);
		DTAG::LexInput->lexicon($new);
	}

	# Return
	return 1;
}
