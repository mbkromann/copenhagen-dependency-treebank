sub cmd_errors {
	my ($self, $graph, $from, $to) = @_;
	$from = 0 if (! defined($from));
	$to = $graph->size() - 1 if (! defined($to));

	# Print error definitions
	my $errors = {};
	my $edgeerrors = {};
	for (my $i = $from; $i <= $to; ++$i) {
		# Skip comment nodes
		my $node = $graph->node($i);
		next if ($node->comment());

		# Test in-edge errors
		my @edgeerrors = ();
		if ($node) {
			foreach my $e (sort {$a->out() <=> $b->out()} @{$node->in()}) {
				my @errorlist = @{$graph->errors_edge($e)};
				foreach my $error (map {$_->[0]} @errorlist) {
					$edgeerrors->{$error} = 1;
					$errors->{$error} = [] 
						if (! exists $errors->{$error});
					push @{$errors->{$error}}, $e->as_string();
				}
				#push @edgeerrors, "    " . $e->as_string() . ": " 
				#		. join(" ", map {$_->[0]} @errorlist) . "\n"
				#	if (@errorlist);
			}
		}

		# Test node errors
		foreach my $error (map {$_->[0]} @{$graph->errors_node($node)}) {
			$errors->{$error} = [] 
				if (! exists $errors->{$error});
			push @{$errors->{$error}}, $i;
		}
		#if (@nodeerrors || @edgeerrors) {
		#	print "$i: " . join(" ", map {$_->[0]} @nodeerrors) . "\n";
		#	print @edgeerrors;
		#}
	}

	# Print all node errors
	foreach my $error (sort(keys(%$errors))) {
		next if ($edgeerrors->{$error});
		print "  " . $error . ": " . join(", ", sort {$a <=> $b} (@{$errors->{$error}})) . "\n";
	}

	# Print all edge errors
	foreach my $error (sort(keys(%$errors))) {
		next if (! $edgeerrors->{$error});
		print "  " . $error . ": " . join(", ", sort 
			{	my ($ain,$aout) = split(/[^0-9]+/, $a);
				my ($bin,$bout) = split(/[^0-9]+/, $b);
				return $ain <=> $bin || $aout <=> $aout;
			} 
			@{$errors->{$error}}) . "\n";
	}

	# Return
	return 1;
}
