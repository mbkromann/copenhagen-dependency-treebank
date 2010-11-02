package FindTypeAtomic;
@FindTypeAtomic::ISA = qw(FindType);

sub shortname {
	my $relset = shift;
	my $rel = shift;
	return exists $relset->{$rel} 
		? $relset->{$rel}[0] : undef;
}

sub match {
    my $self = shift;
    my $graph = shift;
    my $string = shift;
	my $relset = shift;
    my $tparent = $self->{'args'}[0];
	
    # Check for equality
	my $subtypes_only = $self->{'args'}[1];
    return 1 if ($tparent eq $string && ! $subtypes_only);

	# Retrieve canonical names and check for existence and equality
	$string = shortname($relset, $string);
	$tparent = shortname($relset, $tparent);
	return 0 if (! (defined($string) && defined($tparent)));
	return 1 if ($string eq $tparent && ! $subtypes_only);

    # Check relation set   
    return $relset->{$string}[$REL_TPARENTS]->{$tparent};
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return '"' . $args->[0] . '"';
}
