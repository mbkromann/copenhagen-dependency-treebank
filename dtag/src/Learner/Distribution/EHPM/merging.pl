sub merging {
	my $self = shift;
	my $cover = shift;
	my $i = shift;
	my $old_mlog_posterior = shift || 0;

	# Check that merging is valid, ie, $cover->[$i-1] must be a
	# subspace of $cover->[$i]; if not, return immediately
	my $hierarchy = $self->hierarchy();
	my $partition_box = $cover->[$i]->space_box();
	my $subpartition_box = $cover->[$i-1]->space_box();
	return [1e100, undef]
		if (! $hierarchy->box_contains($partition_box, $subpartition_box));

	# Otherwise, return cover produced by merging partition $i with its parent
	my $newcover = $self->merge($cover, $i);
	
	# Debug
 	if ($newcover) {
		print "    "  
            . sprintf("%10s", 
				sprintf("%8g", $newcover->[0] - $old_mlog_posterior))
			. " merge " . $self->print_cover($newcover->[1]) 
			. " from " . $self->print_cover($cover) . "\n";
	}

	# Return
	return $newcover ? $newcover : [1e100, undef];
}

