=item $graph->etypes($etypes) = $etypes

Get/set edge type hash associated with graph.

=cut

sub etypes {
	my $self = shift;

	# Set etypes
	my $interpreter = $self->{'interpreter'};
	if (@_) {
		my $etypes0 = $self->var('etypes') 
			|| ($interpreter ? $interpreter->{'etypes'} : undef) || $etypes;
		my $etypes1 = shift;

		# Copy all missing etypes from $etypes0 to $etypes1
		foreach my $key (keys(%$etypes0)) {
			if (! exists $etypes1->{$key}) {
				$etypes1->{$key} = $etypes0->{$key};
			}
		}

		# Set new etypes
		$self->var('etypes', $etypes1);
	}

	# Return etypes
	return $self->var('etypes', @_) 
		|| ($interpreter ?  $interpreter->{'etypes'} : undef) 
		|| $etypes;
}

