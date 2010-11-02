# $string = $type->print: print $type and return result in $string

sub print {
	my $self = shift;

	# Variable names
	my @vars = ();
	foreach my $v (sort(keys(%$self))) {
		push(@vars, $v)
			if ($v !~ /^_.*$/);
	}

	# Print name of self and parents
	my $string = $self->get_name() 
		. ": super=[" . join(" ", 
			map {get_name(typeobj($_) || $undef)} @{$self->get_super()}) 
		. "]"
		. " lvars=[" 
		. join(" ", map {"$_=" . $self->lvar($_)} @vars)
		. "]\n";
	
	# Return
	return $string
}

