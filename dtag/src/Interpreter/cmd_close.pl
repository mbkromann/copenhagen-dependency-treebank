sub cmd_close {
	my $self = shift;
	my $graph = shift;
	my $options = shift || "";

	# Close graph
	if ($graph) {
		# Clear graph and remove it from graph list
		$self->{'graphs'} = [grep {$_ ne $graph} @{$self->{'graphs'}}];

		# Clear all unmodified graphs
		$self->{'graphs'} = [grep {$_->mtime()} @{$self->{'graphs'}}]
			if ($options =~ /-all/);

		# Open new graph, if graph list is empty
		if (! @{$self->{'graphs'}}) {
			my $new = DTAG::Graph->new($self);
			push @{$self->{'graphs'}}, $new;
		}

		# Check that current graph is legal
		if (($self->{'graph'} || 0) >= scalar(@{$self->{'graphs'}})) {
			$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
		}

		# Update current graph
		$self->cmd_return($self->graph());
	}

	# Return
	return 1;
}
