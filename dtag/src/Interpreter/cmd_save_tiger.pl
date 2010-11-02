sub cmd_save_tiger {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open file and XML writer
	my $encoding = $graph->encoding() || "UTF-8";
	my $output = IO::File->new($file, ">:encoding($encoding)")
		|| return error("cannot open TIGER XML file for writing: $file");
	my $writer = new XML::Writer('OUTPUT' => $output, 'DATA_MODE' => 1,
		'DATA_INDENT' => 2, 'UNSAFE' => 1);

	# Compute corpus name and date
	my $corpus = $file; $corpus =~ s/\.xml//;
	my $date = `date`; chomp($date);

	# Write XML header
	$writer->xmlDecl($encoding);

	# Write XML file 
	$writer->startTag("corpus", "id" => $corpus);

	# Header
	$writer->startTag("head");
		# Meta information
		$writer->startTag("meta");
			$writer->dataElement("name", $corpus);
			$writer->dataElement("date", $date);
			$writer->dataElement("author", "");
			$writer->dataElement("description", "");
			$writer->dataElement("format", "");
			$writer->dataElement("history", "");
		$writer->endTag("meta");

		# Start feature description
		$writer->startTag("annotation");
		$writer->emptyTag("feature", "name" => "word", "domain" => "FREC");

		# Information about features
		my $labels = $graph->labels($self, 500);
		my $vars = $labels->{'_vars'};
		foreach my $f (@$vars) {
			# Describe feature
			$writer->startTag("feature", , "name" => $f, 
					"domain" => "FREC");
				# Describe feature values
				foreach my $v (@{$labels->{$f} || []}) {
					$writer->dataElement("value", "", "name" => 
						(defined($v) && $v ne "") ? $v : "--");
				}
			$writer->endTag("feature");
		}

		# Information about primary edge labels
		$writer->startTag("edgelabel");
		foreach my $e ("--", @{$labels->{'_edges1'}}) {
			$writer->dataElement("value", "", "name" => $e);
		}
		$writer->endTag("edgelabel");

		# Information about secondary edge labels
		$writer->startTag("secedgelabel");
		foreach my $e (@{$labels->{'_edges2'}}) {
			$writer->dataElement("value", "", "name" => $e);
		}
		$writer->endTag("secedgelabel");

		# End feature description
		$writer->endTag("annotation");

	# End header
	$writer->endTag("head");

	# Create secondary edge hash
	my $secondary = {};
	map {$secondary->{$_} = 1} @{$labels->{'_edges2'}};

	# Begin body and process graph
	$writer->startTag("body");
	my $size = $graph->size();
	my $s = 0;
	for (my $first = 0; $first < $size; ++$first) {	
		my $last = $first;
		my $root = $first;
		if ($self->var('tag_segment_ends')) {
			# Method 1: Use existing <s> and </s> marks
			for ( ; $last < $size; ++$last) {
				my $node = $graph->node($last);
				$root = $last if ($node && ! $node->comment());
				last() if ($node->comment() && 
					&{$self->var('tag_segment_ends')}($node->input()));
			}
		} else {
			# Method 2: Find first primary root at or after $first,
			# ie, the first node all of whose incoming edges are
			# secondary, and exit if no root was found.
			$root = $first;
			for (; $root < $size; ++$root) {
				#  Exit if root node isn't a real node
				my $rootnode = $graph->node($root);
				next() if (! $rootnode || $rootnode->comment());

				# Exit if root node has no primary edges
				my $primary = 0;
				foreach my $e (@{$rootnode->in()}) {
					# Primary edge exists if it isn't secondary
					$primary = 1 if (! secondary($secondary, $e->type()));
				}
				last() if (! $primary);
			}
			last() if ($root >= $size);

			# Find yield of first root, and find first and last node in yield
			my $yields = $graph->yields({}, $root)->{$root};
			$first = $yields->[0][0];
			$last = $yields->[scalar(@$yields)-1][1];
			print "root=$root span=$first-$last\n";
		}

		# Output sentence and graph
		++$s;
		$writer->startTag("s", "id" => "s$s");
		$writer->startTag("graph", "root" => "p${s}_$root");

		# Output terminals in yield
		$writer->startTag("terminals");
		for (my $id = $first; $id <= $last; ++$id) {
			# Retrieve node and skip if non-existent or comment
			my $node = $graph->node($id);
			next() if (! $node || $node->comment());

			# Construct hash with feature-value pairs
			my $fvpairs = {};
			map {	my $str = $graph->reformat($self, $_, $node->var($_)); 
					$str = "--" if (! defined($str) || $str eq "");
					$fvpairs->{$_} = $str
				} @$vars;

			# Write terminal tag for node
			$writer->emptyTag("t", "id" => "w${s}_$id", 
				"word" => $node->input(), %$fvpairs);
		}
		$writer->endTag("terminals");

		# Output non-terminals in yield
		$writer->startTag("nonterminals");
		for (my $id = $first; $id <= $last; ++$id) {
			# Retrieve node and skip if not in yield
			my $node = $graph->node($id);
			next() if (! $node || $node->comment());

			# Construct hash with feature-value pairs
			my $fvpairs = {};
			map {	my $str = $graph->reformat($self, $_, $node->var($_)); 
					$str = "--" if (! defined($str) || $str eq "");
					$fvpairs->{$_} = $str
				} @$vars;

			# Write non-terminal tag for node
			$writer->startTag("nt", "id" => "p${s}_$id", 
				"word" => $node->input(), %$fvpairs);

			# Write head edge
			$writer->emptyTag("edge", "idref" => "w${s}_$id",
				"label" => "--");

			# Write other outgoing edges within yield
			foreach my $e (@{$node->out()}) {
				# Check that edge is within yield
				my $idref = $e->in();

				# Write edge
				if (secondary($secondary, $e->type())) {
					# Secondary edge
					$writer->emptyTag("secedge", "idref" => "p${s}_$idref", 
						"label" => $e->type());
				} else {
					# Primary edge
					$writer->emptyTag("edge", "idref" => "p${s}_$idref", 
						"label" => $e->type());
				}
			}

			# Close non-terminal tag
			$writer->endTag("nt");
		}

		# End terminals, graph, and s
		$writer->endTag("nonterminals");
		$writer->endTag("graph");
		$writer->endTag("s");

		# Set $first to $last
		$first = $last;
	}

	# End body and corpus
	$writer->endTag("body");
	$writer->endTag("corpus");
	
	# Close writer and file
	$writer->end();
	$output->close();
	print "exported graph to TIGER-XML in file $file\n" if (! $self->quiet());

	# Return
	return 1;
}

sub secondary {
	my $secondary = shift;
	my $type = shift;

	# Check whether edge is secondary
	my $sec = 0;
	foreach my $s (keys(%$secondary)) {
		$sec = 1 if ($s eq $type);
	}

	# Return
	return $sec;
}
