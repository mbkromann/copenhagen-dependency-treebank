sub varkey {
	my ($self, $bindings, $var) = @_;
	my $key = $bindings->{'vars'}{defined($var) ? $var : ""};
	return defined($key) ? $key : "";
}

