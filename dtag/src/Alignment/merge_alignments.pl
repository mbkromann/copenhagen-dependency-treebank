# Merge all nodes on each alignment edge
sub merge_alignments {
	# Parameters
	my ($self, $tunits) = @_;

	# Merge all nodes on each alignment edge
	foreach my $aedge (@{$self->edges()}) {
		my @nodes = ();
		
		# Compute innodes
		foreach my $n (@{$aedge->inArray()}) {
			push @nodes, node2int($n, $aedge->inkey());
		}

		# Compute outnodes
		foreach my $n (@{$aedge->outArray()}) {
			push @nodes, node2int($n, $aedge->outkey());
		}

		# Merge all nodes
		my $n0 = shift(@nodes);
		foreach my $n (@nodes) {
			merge_tunit($tunits, $n0, $n);
		}
	}
}

