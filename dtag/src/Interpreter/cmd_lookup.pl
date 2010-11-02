sub cmd_lookup {
	my $self = shift;
	my $graph = shift;
	my $input = shift;

	my $lexicon = $self->lexicon();
	my @types = sort {$a->[0] cmp $b->[0] || $a->[1] cmp $b->[1]} 
		@{$lexicon->lookup(lc($input))};
	print "input = $input\n" . "matches = " . join(" ", 
		map {$_->[0] . "/" . $_->[1]} @types) . "\n";
}


