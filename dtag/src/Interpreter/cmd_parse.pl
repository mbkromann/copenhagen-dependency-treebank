sub cmd_parse {
	my $self = shift;
	my $graph = shift;
	my $cmd = shift;

	# Create input object
	my $input = undef; 
	if ($cmd) {
		# Text input: unsegmented string
		$input = Text->new();
		$input->input('', $cmd);
	} else {
		# Graph input: segmented string
		$input = $graph;
	}

	# Create new parse object
	my $parse = DTAG::Parse->new();
}
