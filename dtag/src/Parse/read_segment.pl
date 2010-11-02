=item $parse->read_segments



=cut

sub read_segments {
	my $self = shift;
	my $n = abs(shift || 1);

	# Check that input stream exists
	my $input = $self->input();
	return error("No input stream provided for parse") 
		if (! defined($input));
	my $time1 = $self->time1();

	# Find open lexemes
	my $openlex = $self->open_lexemes();

	# Find segments
	my $segments = [];
	while ($n > 0) {
		# Find all lexemes starting at this position
		my $lexemes = $input->lookup($time1);
		push @$openlex, @$lexemes;

		# Find segment end
		my $time2 = 1e100;
		if (@$openlex) {
		} else {
			# No open lexemes: resort to $input->next_lexeme()
		}

		# Decrement $n
		--$n;
	}	
}
