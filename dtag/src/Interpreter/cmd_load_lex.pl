sub cmd_load_lex {
	my $self = shift;
	my $graph = shift;
	my $lexfile = shift;

	# Check that the lexicon is defined
	return error("No lexical database specified.") 
		if (! $self->lexicon());
	return error("Illegal lexicon file $lexfile.")
		if (! $lexfile);

	# Open lexicon file
	open("LEX", "< $lexfile") 
		|| return error("cannot open lexicon file for reading: $lexfile");
	
	# Read LEX file line by line
	print "loading lexicon...\n" if (! $self->quiet());
	my $program = "no strict;\n";
    while (my $line = <LEX>) {
		$program .= $line;
	}

	# Close LEX file
	close("LEX");

	# Evaluate lexicon file, and save it as new lexicon, if it
	# evaluates to a Lexicon object
	print "parsing lexicon...\n" if (! $self->quiet());
	my $return = eval("$program");
	print "errors = $@\n" if ($@);

	# Replace current lexicon with LexInput->lexicon()
	$self->lexicon(DTAG::LexInput->lexicon()) 
		if (DTAG::LexInput->lexicon());

	# Compile lexicon
	print "compiling lexicon...\n" if (! $self->quiet());
	$self->lexicon()->compile();

	# Return 
	return;
}
