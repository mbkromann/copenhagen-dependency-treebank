sub compile_phonh {
	my $self = shift;
	my $phonhash = $self->{'phonhash'};
    my $phonsub = $self->{'phonsub'};

    # Compile regular expressions in phonhash into phonsub
    foreach my $op (keys %$phonhash) {
		my $code = 'sub { my $s = shift; $s =~ ' 
			.  $phonhash->{$op} 
			. '; return $s;}';
        $phonsub->{$op} = eval($code);
    }

	# Return
	return $self;
}
