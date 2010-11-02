sub lookup_hash {
	my $self = shift;
	my $key = lc(shift);
	my $hash = shift;
	my $fhash = shift;

	# Lookup edge in ordinary lexicon
	my $alexlist = $self->alex();
	my $alexs = [];
	if (exists $hash->{$key} && ! exists $fhash->{$key}) {
		push @$alexs, map {$alexlist->[$_]->clone()} @{$hash->{$key}};
	}

	# Lookup edge among regular expressions
	my $regexp2sub = $self->var('regexps');
	foreach my $regexp (keys %{$hash->{'__regexps__'}}) {
		my $sub = $regexp2sub->{$regexp};
		push @$alexs,
				(map {$alexlist->[$_]->clone()} 
					@{$hash->{'__regexps__'}{$regexp}})
			if (&$sub($key));
	}
	
	# Return empty list
	return $alexs;
}

