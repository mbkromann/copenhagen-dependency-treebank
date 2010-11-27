sub keygraph {
	my ($self, $graph, $bindings) = (shift, shift, shift);
	my @vars = @_;
	my $key = $self->varkey($bindings, @vars);
	my $var1 = shift(@vars);
	foreach my $var (@vars) {
		my $nkey = $self->varkey($bindings, $var);
		if ($key ne $nkey) {
			$self->error($graph, "Variables " . join(" ", $var1, @vars) 
				. " must have the same key, but didn't: "
				. $var1 . "@" . $key . ","
				. $var . "@" . $nkey);
		}
	}
	return $graph->graph($key);
}
