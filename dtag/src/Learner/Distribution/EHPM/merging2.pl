sub merging2 {
	my $self = shift;
	my $cover = shift;
	my $i = shift;
	my $old_mlog_posterior = shift || 0;

	# Return cover produced by merging partition $i with its parent
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

