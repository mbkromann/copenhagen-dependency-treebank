# $type ::= $lexicon->path2type($path, $source)


# $L->path2type("mand:n1|pl|def", undef)
# $L->path2type(["pl", "def"], {...mand:n1...})

sub path2type {
	my $self = shift;
	my $path = shift;
	my $source = shift || undef;

	# Convert path into array
	if (! UNIVERSAL::isa($path, 'ARRAY')) {
		$path = [split(/\|/, $path)];
	}

	# Find original root type
	my $root = undef;
	my $next = shift(@$path);
	if ($source) {
		# Copy transformed type
		$root = $self->copy_type(
			[$source, $source->var('trans')->{$next}], $source);

		# Name of transformed is name of source plus "|$next"
		$root->lvar('_name', 
			($source->lvar('_name') || '') . '|' . $next);

		# Super types of transformed are defined by xsuper
		$root->lvar('_super', $root->lvar('xsuper') || []);
	} elsif ($root = typeobj($next)) {
		# Copy lexical type
		$root = $self->copy_type($root);
	} else {
		return undef;
	}

	# Return result
	if (@$path) {
		# Path is still non-empty; root becomes new source
		return $self->path2type($path, $root);
	} else {
		# Path is empty: root is the result

		# Clean up: delete 'trans' and 'roots' variables, as they are
		# irrelevant in a compiled type (= $root)
		#$root->lvar('trans', undef);
		#$root->lvar('_roots', undef);
		#$root->lvar('_mark', undef);
		#$root->lvar('phon', undef);

		return $root;
	}
}


