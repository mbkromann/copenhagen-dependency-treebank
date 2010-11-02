package FindProc;

sub utf8print {
    return 1;
}

sub print {
    my $self = shift;
    my $neg = $self->{'neg'} ? (utf8print() ? "¬" : "!") : "";
    my $type = ref($self);
    return "$type(" . join(",",
        map {UNIVERSAL::isa($_, 'FindProc') ? $_->print() : "$_"}
            @{$self->{'args'}}) . ")";
}

sub pprint {
    my $self = shift;
    my $neg = $self->{'neg'} ? (utf8print() ? "¬" : "!") : "";
    # Print 
    return "$neg" . $self->_pprint();
}

sub _pprint {
    my $self = shift;
    my $type = ref($self);
    return "$type(" . join(",",
        map {UNIVERSAL::isa($_, 'FindProc') ? $_->pprint() : "$_"}
            @{$self->{'args'}}) . ")";
}


sub keygraph {
	my ($self, $graph, $bindings) = (shift, shift, shift);
	my @vars = @_;
	my $var1 = shift(@vars);
	my $key = $self->varkey($bindings, @vars);
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

sub varkey {
	my ($self, $bindings, $var) = @_;
	my $key = $bindings->{'vars'}{defined($var) ? $var : ""};
	return defined($key) ? $key : "";
}

sub error {
	my $self = shift;
	my $graph = shift;
	my $error = shift;
	$graph->interpreter()->abort(1);
	DTAG::Interpreter::error($error . " in " . $self);
}

sub varbind {
    my $self = shift;
    my $bindings = shift;
    my $bind = shift;
    my $var = shift;

    return (defined($bind) && exists $bind->{$var})
        ? $bind->{$var}
        : $bindings->{$var};
}

