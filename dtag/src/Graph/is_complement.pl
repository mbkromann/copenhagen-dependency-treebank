sub is_complement {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a complement
	my $type = "" . ((ref($edge) ? $edge->type() : $edge) || "");

	# Return false if edge is a landing edge
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
    $type =~ s/[()]//g;
	$type =~ s/\/ATTR[0-9]+//g;

	# See if it is known
	if ($self->interpreter()->is_relset_etype($type, "COMPLEMENT",
			$self->relset())) {
		return 1;
	} elsif (grep {$type eq $_} @{$self->etypes()->{'comp'}}) {
		return 1;
	} elsif (grep {lc($type) eq $_} @{$self->etypes()->{'comp'}}) {
		return 1;
    } elsif ($type =~ /^<(.*:)?([^:]*):[0-9]+>$/) {
        my ($head, $tail) = ($1 || "", $2);
        my $return = 1;
        map {$self->is_complement($_) || ($return = 0)} split(/:/, $head);
        return $self->is_complement($tail) && $return;
    } elsif ($type =~ /^([^\.]+)\.([^\.]+)$/) {
		return $self->is_complement($1) && $self->is_dependent($2);
	} elsif ($type =~ /^([^\|]+)\|(.*)$/) {
		return $self->is_complement($1) && $self->is_dependent($2);
	}

	# Otherwise return 0
	return 0;
}

