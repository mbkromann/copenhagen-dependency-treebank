sub clear {
	my $self = shift;
	
	# Delete all tied lists in lexicon
	foreach my $list ('db_phon') {
		my $listobj = $self->{$list};
		while ($listobj->length()) {
			$listobj->pop();
		};
	}

	# Delete all tied hashes in lexicon
	foreach my $hash ('roots', 'types', 'phonhash', 'relations',
			'super', 'sub') {
		my $hashobj = $self->{$hash};
		while (my ($key, $value) = each(%$hashobj)) {
			delete $hashobj->{$key};
		}
	}

	# Delete phonsub, utypes, ntypes
	$self->{'phonsub'} = {};
	$self->{'utypes'} = {};
	$self->{'ntypes'} = {};

	return 1;
}
