=item $graph->node_add($pos, $node) = $node

Insert node $node at position $pos in graph.

=cut

sub node_add {
	my $self = shift;
	my $pos = shift;
	my $node = shift;

	# Check that $pos is a legal value
	my $nodes = $self->size();
	$pos = $nodes if ((! defined($pos) || ! length($pos)) 
		|| ($pos < 0) || ($pos > $nodes));

	# Insert new word into word list
	splice(@{$self->nodes()}, $pos, 0, $node);

	# Set node id
	my $ids = $self->ids();
	my $id = $node->var("id");
	$id = $pos if (! defined($id));
	if ($ids->{$id}) {
		my $subid = 1;
		while ($ids->{$id . ".$subid"}) {
			++$subid;
		}
		$id = $id . "." . $subid;
	}
	$node->var("id", $id);
	
	# Recalculate graph ids
	if ($pos == $nodes) {
		# Last word: update incrementally
		$ids->{$id} = $pos;
	} else {
		# Non-last word: recompile all ids
		$self->compile_ids();
	}

	# Update edges in words at or after $pos
	for (my $i = $pos; $i <= $nodes; ++$i) {
		my $n = $self->node($i);
		if (! defined($n)) {
			print "ERROR: undefined node $i\n";
			return;
		}

		# Process in-edges
		foreach my $e (@{$n->in()}) {
			if ($e->in() > $e->out()) {
				$e->in($e->in() + 1);
				$e->out($e->out() + 1) if ($e->out() >= $pos);
				#print "[increment in-edge in $i]\n";
			}
		}

		# Process out-edges
		foreach my $e (@{$n->out()}) {
			if ($e->out() > $e->in()) {
				$e->out($e->out() + 1);
				$e->in($e->in() + 1) if ($e->in() >= $pos);
				#print "[increment out-edge in $i]\n";
			}
		}
	}

	# Return
	return $node;
}

