sub cmd_list_matchno {
	my $self = shift;
	my $match = shift;
	my $file = shift;
	my $binding = shift;

	my @vars = sort(keys(%$binding));
	return "match $match = $file: "
		. "(" . join(", ", @vars) . ")"
		. " = (" . join(", ", map {$binding->{$_}} (@vars)) . ")";
}
