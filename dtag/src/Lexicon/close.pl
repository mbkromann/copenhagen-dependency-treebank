sub close {
	my $self = shift;

	# Delete references to tied objects
	foreach my $var ('db_phon', 'db_root', 'db_type', 'db_phonh',
			'db_rel', 'db_super', 'db_sub') {
		$self->{$var} = undef;
	}

	# Untie tied objects
	foreach my $var ('roots', 'types', 'phonops', 'phonhash', 'relations', 
			'super', 'sub') {
		my $obj = $self->{$var};
		$self->{$var} = undef;
		untie(%$obj);
		$self->{$var} = undef;
	}

	# Delete all hash elements
	foreach my $hashname (keys(%$self)) {
		my $hash = $self->{$hashname};
		if (ref($hash) && UNIVERSAL::isa($hash, 'HASH')) {
			while (my ($key, $val) = each(%$hash)) {
				delete $hash->{$key};
			}
		}
		delete $self->{$hashname};
	}
}

