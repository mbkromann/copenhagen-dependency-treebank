sub uniq {
	my @result = ();
	my $last = undef;
	foreach (@_) {
		push @result, $_ 
			if (defined($_) && (! (defined($last) && $last eq $_)));
		$last = $_;
	}
	return @result;
}

