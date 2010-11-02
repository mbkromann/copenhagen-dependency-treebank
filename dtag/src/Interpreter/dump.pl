sub dump {
	my $self = shift;
	my $obj = shift;

	# Find class of object
	my $ref = ref($obj) || "";
	my $pre = "";
	my $post = "";
	if ($ref && $ref !~ /^(ARRAY|HASH|CODE)$/) {
		$pre = "bless( ";
		$post = ", $ref )";
	}

	# Process object recursively
	if (! $ref) {
		return defined($obj) ? qq("$obj") : "undef";
	} elsif (UNIVERSAL::isa($obj, "ARRAY")) {
		return "$pre" . "[" 
			. join(", ", map {$self->dump($_)} @$obj) 
			. "]$post";
	} elsif (UNIVERSAL::isa($obj, "HASH")) {
		return "$pre" . "{"
			. join(", ", map {(defined($_) ? qq("$_") : "undef") . " => " . 
				$self->dump($obj->{$_})} sort(keys(%$obj))) 
			. "}$post";
	} elsif (UNIVERSAL::isa($obj, "CODE")) {
		return $pre . "sub { \"DUMMY\" }" . $post;
	} 

	# Return unknown if all else fails
	return "__UNKNOWN__";
}
	
