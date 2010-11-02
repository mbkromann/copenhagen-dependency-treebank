sub is_adjunct {
	my ($self, $edge) = @_;
	# Return 1 if edge is an adjunct edge 
	my $type = "" . ((ref($edge) ? $edge->type() : $edge) || "");

	# Return 1 if edge is '+'
	return 1 if ($type eq "+");

	# Return 0 if edge is a landing edge
	return 0 if ($self->is_landing($edge));

	# Remove edge decorations
	$type =~ s/^[:;+]//g;
	$type =~ s/^[¹²³^]+//g;
    $type =~ s/^\¤//g;
	$type =~ s/[¹²³^]+$//g;
	$type =~ s/\#$//g;
	$type =~ s/^@//g;
	$type =~ s/\/.*$//g;
	$type =~ s/\*//g;
	$type =~ s/[()+]//g;
	$type =~ s/\/ATTR[0-9]+//g;

	# See if reduced edge matches adjunct
	if ($self->interpreter->is_relset_etype($type, "ADJUNCT",
			$self->relset())) {
		return 1;
	} elsif (grep {$type eq ($_ || "")} @{$self->etypes()->{'adj'}}) {
		return 1;
	} elsif (grep {lc($type) eq ($_ || "")} @{$self->etypes()->{'adj'}}) {
		return 1;
    } elsif ($type =~ /^<(.*)@(.*):[0-9]+>$/) {
        my ($head, $tail) = ($1 || "", $2);
        my $return = 1;
        map {$self->is_known_edge($_) || ($return = 0)} split(/:/, $head);
        map {$self->is_dependent($_) || ($return = 0)} split(/:/, $tail);
        return $return;
    } elsif ($type =~ /^<(.*:)?([^:]*):[0-9]+>$/) {
        my ($head, $tail) = ($1 || "", $2);
        my $return = 1;
        map {$self->is_dependent($_) || ($return = 0)} split(/:/, $head);
        map {$self->is_dependent($_) || ($return = 0)} split(/:/, $tail);
        return $return;
	} elsif ($type =~ /^<([^:]*)(:(.*))?:[0-9]+>$/) {
		my ($head, $tail) = ($1, $3 || "");
		my $return = 1;
		map {$self->is_dependent($_) || ($return = 0)} split(/:\./, $tail);
		return $self->is_adjunct($head) && $return;
	} elsif ($type =~ /^([^:]+)\.([^:]+)$/) {
		return $self->is_adjunct($1) && $self->is_dependent($2);
    } elsif ($type =~ /^([^\|]+)\|(.*)$/) {
           return $self->is_adjunct($1) && $self->is_dependent($2);
    } elsif ($type =~ /^([^\|]+)\&(.*)$/) {
           return $self->is_adjunct($1) && $self->is_dependent($2);
	}

	# Otherwise return 0
	return 0;
}

