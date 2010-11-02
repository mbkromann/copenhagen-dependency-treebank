package HashVal;
@HashVal::ISA = qw(ValOp);

use overload
    '""' => \& print;

sub preset {
	my $self = shift;
	my $value = shift;

	# Check that $value is a hash reference
	if (ref($value) ne "HASH") {
		$value = { };
	}

	# Add all pairs in plus-hash
	my $plus = $self->plus();
	foreach my $key (keys %$plus) {
		if (! (exists $value->{$key})) {
			$value->{$key} = $plus->{$key};
		}
	}

	# Return value
	return $value;
} 

sub postset {
	my $self = shift;
	my $value = shift;

	# Delete all keys in minus-list
	foreach my $key (@{$self->minus()}) {
		delete $value->{$key};
	}

	# Return value
	return $value;
}

sub print {
    my $self = shift;

	# Print 
	return "hash([" 
		. join(",", map {"$_=" . $self->plus()->{$_}} 
			sort(keys(%{$self->plus()}))) 
		. "]-[" 
		.  join(",", @{$self->minus()}) . "], " 
		.  $self->inherit() . ")";
}

