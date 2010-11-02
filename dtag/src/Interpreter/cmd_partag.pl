sub cmd_partag {
	my $self = shift;
	my $alignment = shift;
	my $tkey = shift;

    # Check that $graph is an Alignment
    if (! UNIVERSAL::isa($alignment, 'DTAG::Alignment')) {
        error("no active alignment");
        return 1;
    }

	# Find source and target graphs
	my $skey = [grep {$_ ne $tkey} keys(%{$alignment->graphs()})]
		->[0];
	my $source = $alignment->graph($skey);
	my $target = $alignment->graph($tkey);
	print "target graph = " . $target->file() . "\n";
	print "source graph = " . $source->file() . "\n";
	

	# TRANSFER DEPENDENCIES FROM SOURCE TO TARGET
    my $n = $source->size();
	my $scount = 0;
	my $tcount = 0;
    for (my $i = 0; $i < $n; ++$i) {
        # Find node and skip if comment
        my $node = $source->node($i);
        next() if $node->comment();
        foreach my $e (@{$node->in() || []}) {
			# Find edge parameters
			++$scount;
			my $type = $e->type();
			my $sin = $e->in();
			my $sout = $e->out();

			# Find alignment edges for $sin and $sout
			my $inalign = $alignment->edge(
				$alignment->node_edges($skey, $sin)->[0]);
			my $outalign = $alignment->edge(
				$alignment->node_edges($skey, $sout)->[0]);
			next() if (! (defined($inalign) && defined($outalign)));

			# Create list with potential target edges
			my $tedges = [];
			print "$skey$sin(" . $inalign->string() . ")" 
				. " $type " 
				. "$skey$sout(" .  $outalign->string() . ")" . "\n";

			# 1. Add target edge A' -{r}-> B' given source
			# edge A -{r}-> B and alignments A -- A' and B -- B'
			if (($inalign->signature() eq $skey . "1" . $tkey . "1")
					&& ($outalign->signature() eq $skey . "1" . $tkey . "1")) {
				push @$tedges,
					Edge->new($inalign->inArray()->[0],
						$outalign->inArray()->[0],
						$type);
			}

			# Print created edges
			foreach my $e (@$tedges) {
				print "    " . $e->print() . "\n";
				$target->edge_add($e);
				++$tcount;
			}
        }
    }

	# Print debugging
	print "Converted $scount source edges into $tcount target edges\n";

	# Return
	return 1;
}
