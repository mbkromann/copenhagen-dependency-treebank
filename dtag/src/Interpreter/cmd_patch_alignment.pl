sub cmd_patch_alignment {
	my $self = shift;
	my $alignment = shift;
	my $graph = shift;
	my $diff = shift;
	my $key = shift;
	$graph->offset(0);
	
	# Compute word mapping by processing diff commands
	my $wordmap = {};
	my $i = 0;
	my $imax = $graph->size() - 1;
	my $offset = 0;
	foreach my $spec (@$diff) {
		# Read command
		my ($cmd, $a, $b) = @$spec;
		my ($o, $a1, $a2, $b1, $b2) = @$cmd;

		# Move counter $i forward to $a1
		for ( ; $i < $a1; ++$i) {
			$wordmap->{$i} = $i + $offset;
		}
		$i = $a2;
		$offset += ($b2-$b1)-($a2-$a1);
	}
	for ( ; $i <= $imax; ++$i) {
		$wordmap->{$i} = $i + $offset;
	}

	# Adjust edges in alignment
	my $edges = $alignment->edges();
	my @newedges = ();
	for (my $i = 0; $i < scalar(@$edges); ++$i) {
		my $edge = $edges->[$i];

		# Adjust in-nodes
		my $skip = 0;
		my $newedge = $edge->clone();
		if ($edge->inkey() eq $key) {
			my $array = patchAlignmentArray($wordmap, $edge->inArray());
			$newedge->inArray($array);
			$skip = 1 if (! defined($array));
		}

		if ($edge->outkey() eq $key) {
			my $array = patchAlignmentArray($wordmap, $edge->outArray());
			$newedge->outArray($array);
			$skip = 1 if (! defined($array));
		}
		push @newedges, $newedge if (! $skip);
	}

	# Delete edges
	for (my $i = $#$edges; $i >= 0; --$i) {
		$alignment->del_edge($i);
	}

	# Add edges
	foreach my $e (@newedges) {
		$alignment->add_edge($e);
	}
}


sub patchAlignmentArray {
	my $wordmap = shift;
	my $array = shift;
 	my $newarray = [];
	for (my $i = 0; $i < scalar(@$array); ++$i) {
		my $pos = $array->[$i];
		my $newpos = $wordmap->{$pos};
		push @$newarray, $newpos;
		return undef if (! defined($newpos));
	}
	return $newarray;
}
