sub insert_regexp {
	my $self = shift;
	my $hash = shift;
	my $key = shift;
	my $id = shift;

	# Find regexp hash
	if (! exists $hash->{'__regexps__'}) {
		$hash->{'__regexps__'} = {};
	}
	my $hregexps = $hash->{'__regexps__'};
	my $idlist = (exists $hregexps->{$key}) ? $hregexps->{$key} : [];

	# Compile regexp
	my $regexps = $self->var('regexps');
	if (! exists $regexps->{$key}) {
		my $sub = eval("sub { my \$s = shift; return (\$s =~ $key) ? 1 : 0 }");
		$self->{'regexps'}{$key} = $sub;
	}

	# Insert id into list of ids
	$hash->{'__regexps__'}{$key} = [ sort($id, @$idlist) ];
}
