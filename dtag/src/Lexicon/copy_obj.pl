sub copy_obj {
	my $self = shift;
	my $obj = shift;
	my $src = shift;

	# Copy object
	my $copy = undef;
	if (! ref($obj)) {
		# $obj is atomic: do nothing
		$copy = $obj;
	} elsif (UNIVERSAL::isa($obj, "ARRAY")) {
		# $obj is an array reference
		$copy = [];
		bless($copy, ref($obj)) if (ref($obj) ne "ARRAY");

		# Copy array elements
		for (my $i = 0; $i < scalar(@$obj); ++$i) {
			if (ref($src) && UNIVERSAL::isa($obj->[$i], "SrcVal")) {
				# Replace src value with 
				$copy->[$i] = $obj->[$i]->value($src);
			} else {
				$copy->[$i] = $self->copy_obj($obj->[$i], $src);
			}
		}
	} elsif (UNIVERSAL::isa($obj, "HASH")) {
		# $obj is a hash reference
		$copy = {};
		bless($copy, ref($obj)) if (ref($obj) ne "HASH");

		# Copy hash entries
		foreach my $key (keys(%$obj)) {
			if (ref($src) && UNIVERSAL::isa($obj->{$key}, "SrcVal")) {
				# Replace src value with its value
				$copy->{$key} = $obj->{$key}->value($src);
			} else {
				$copy->{$key} = $self->copy_obj($obj->{$key}, $src);
			}
		}
	} else {
		# $obj is some other blessed object
		$copy = $obj;
	}

	# Return copy
	return $copy;
}

