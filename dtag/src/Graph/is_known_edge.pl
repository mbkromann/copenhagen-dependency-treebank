sub is_known_edge {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a complement
	my $type = "" . ((ref($edge) ? $edge->type() : $edge) || "");
    $type =~ s/^[:;+]//g;
    $type =~ s/^[¹²³^]+//g;
	$type =~ s/[¹²³^]+$//g;
    $type =~ s/\#$//g;
	$type =~ s/[()]//g;


	# Normalize edge
	if ($self->interpreter()->is_relset_etype($type, "ANY",
			$self->relset())) {
		return 1;
	} elsif ($self->is_dependent($type)) {
		return 1;
	} elsif ($type =~ /^\[(.*)\]$/) {
		return $self->is_dependent($1) ? 1 : 0;
	} else {
		return (grep {$type eq $_} (map {@{$self->etypes()->{$_}}} 
				keys(%{$self->etypes()}))) 
			? 1 : 0;
	}
}

