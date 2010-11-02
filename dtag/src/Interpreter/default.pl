sub default {
	while (my $value = shift) {
		return $value if (defined($value));
	}
}

