sub string {
	my $self = shift;
	my $offsets = shift || {};

	# Get creator
	my $creator = $self->creator();
	my $ctext = "";
	$ctext = " (manually approved)" if ($creator < 0);
	$ctext = " (suggested by DTAG)" if ($creator == -100);
	$ctext = " (suggested by external aligner)" if ($creator <= -101);
	$ctext = " (manually created)" if ($creator >= 0);

	return 
		$self->outkey() . join("+", 
			map {$_ - ($offsets->{$self->outkey} || 0)} @{$self->outArray()}) 
		. " " . $self->type() . " "
		. $self->inkey() . join("+", 
			map {$_ - ($offsets->{$self->inkey} || 0)} @{$self->inArray()}) 
		. "   " . $ctext;
}
