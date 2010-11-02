sub is_relset_etype {
	my $self = shift;
	my $etype = shift;
	my $class = shift;
	
	# Find relset and info for $etype
	my $relset = shift || $self->relsets($self->relset());
	return 0 if (! defined($relset));
	my $info = $relset->{$etype};
	return 0 if (! defined($info));
	my $tparents = $info->[$REL_TPARENTS];
	return 0 if (! defined($tparents));

	# Find canonical name for class
	return 0 if (! $relset->{$class});
	my $classname = $relset->{$class}[$REL_SNAME];
	return $info->[$REL_SNAME] eq $classname 
		|| $tparents->{$classname};
}
