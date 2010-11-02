sub print {
	my $self = shift;
	
	my $i = -1;
	return ref($self) . "\noutcomes:\n" 
		. join("\n", map {++$i; "$i=" . DTAG::Interpreter::dumper($_)} @{$self->outcomes()}) . "\n"
		. "\n\ndata: "
		. join(" ", @{$self->data()}) . "\n";
}

