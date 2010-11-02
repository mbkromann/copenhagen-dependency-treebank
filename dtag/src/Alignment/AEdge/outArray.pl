sub outArray {
	my $self = shift;
    if (@_) {
    	my $array = shift;
    	$self->out(($#$array == 0) ? $array->[0] : $array);
	}
	my $out = $self->out();
	return UNIVERSAL::isa($out, "ARRAY") ? $out : [ $out ];
}
