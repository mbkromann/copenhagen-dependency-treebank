sub dtag2cfg {
	my $self = shift;
	my $file = shift;
	my @vars = @_;

	my $s = "";

	sub cfgprint {
		my $node = shift;
		return join(" / ", shift, map {
			my $val = $node->var($_);
			$val = "" if (! defined($val));
			$val =~ s/'/\\'/g;
			"('" . ($val || "") . "')"} @_);
	}

	# Process each node in the graph
	my $sent = 0;
	for (my $n = 0; $n < $self->size(); ++$n) {
		my $node = $self->node($n);
		if (! $node->comment()) {
			# Print word
			$s .= "phrase($sent, " . cfgprint($node, $n, @vars) . ", ";

			# Find dependents
			my $left = [];
			my $right = [];
			foreach my $e (@{$node->out()}) {
				if ($self->is_dependent($e)) {
					if ($e->in() < $n) {
						push @$left, $e;
					} else {
						push @$right, $e;
					}
				}
			} 

			# Sort dependents by word order
			$left = [sort {$a->in() <=> $b->in()} @$left];
			$right = [sort {$a->in() <=> $b->in()} @$right];

			# Print dependents
			$s .= "[" . join(", ", map {"'" . $_->type() . "' = " 
				. cfgprint($self->node($_->in()), 
				$_->in(), @vars)} @$left) 
				. "], "; 
			$s .= "[" . join(", ", map {"'" . $_->type() . "' = " 
				. cfgprint($self->node($_->in()), 
				$_->in(), @vars)} @$right) 
				. "]).\n"; 
		} else {
			my $input = $node->input();
			++$sent if ($input =~ /<[sS]>/);
		}
	}

	open(OFH, "> $file"); 
	print OFH $s;
	close(OFH);
}

