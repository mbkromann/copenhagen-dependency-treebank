sub print {
	my $self = shift;
	my $hierarchy = $self->hierarchy();

	# Print EHPM
	my $s = # "EHPM $self hierarchy=$hierarchy\n" . 
		"total=" . $self->total() 
		. " mlogp=" . $self->var('mlogp') 
		. " truemlogp= " . $self->var('true_mlogp') . "\n";

	# Print cover
	my $i = 0;
	foreach my $p (@{$self->cover()}) {
		$s .= "cover[$i]:"
			. " spacebox=" .  $hierarchy->print_box($p->space_box()) 
			. " count=" . $p->count() 
			. " w=" . ($p->count() / $self->total() / ($p->prior_mass() || 1))
			. " pmass=" . sprintf("%.6g", $p->prior_mass())
			. " mlogP=" . sprintf("%.6g", $p->mlog_posterior()) 
			.  "\n";
		++$i;
	}

	# Return string
	return $s;
}	
