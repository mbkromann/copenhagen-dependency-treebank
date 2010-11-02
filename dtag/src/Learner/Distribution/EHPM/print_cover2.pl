sub print_cover2 {
	my $self = shift;
	my $info = shift || "";
	my $cover = shift;
	my $mlogp = shift;
	my $rmlogp = shift;

	# Round off
	return ($info ? "$info " : "") 
		. ($mlogp < $self->var('true_mlogp') ? '+' : '-') 
		. "mlogp=" . sprintf("%4g", $mlogp) 
		. (defined($rmlogp) ? " rmlogp=" . sprintf("%4g", $rmlogp) : "")
		. " cover=" . $self->print_cover($cover)
		. " counts=[" . 
				join(",", map {scalar(@{$_->data()->data()})} @$cover)
			. "]" 
		. "\n";
}
