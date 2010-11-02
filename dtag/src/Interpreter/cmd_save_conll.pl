sub cmd_save_conll {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $filterstring = "isa(SYN+PRIM)";

	# Edge filter
	my $edge_filter = $self->edge_filter("$filterstring");
	my $pos = $graph->layout($self, 'pos') || sub {return 0};
	my $edgefiltersub = sub { 
		return defined($edge_filter) && defined($_) 
			? $edge_filter->match($graph, $_->type())
			: ! &$pos($graph, $_); 
		};
		
	# Calculate line numbers
	my $lines = [];
	my $line = 0;
	my $rightboundary = 0;
	my $boundaries = {};
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();
		if (! $node->comment()) {
			$lines->[$i] = ++$line;

            # Update right boundary
            foreach my $e (grep {&$edgefiltersub($_)} @{$node->in()}) {
                my $n = $e->out();
                $rightboundary = $n if ($n > $rightboundary);
            }
            foreach my $e (grep {&$edgefiltersub($_)} @{$node->out()}) {
                my $n = $e->in();
                $rightboundary = $n if ($n > $rightboundary);
            }
		} 
		
		if ($rightboundary <= $i) {
			$line = 0;
			$boundaries->{$i} = 1;
		}
	}

	# Open CONLL file
	open("CONLL", "> $file") 
		|| return error("cannot open file for writing: $file");

	# Select variable for POSTAG/CPOSTAG
	my $tag = $self->option('conll_postag') || "tag";
	my $ctag = $self->option('conll_cpostag') || "tag";

	# Write CONLL file line by line
	my $prevblank = 1;
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);

		# Process non-comment nodes
		my $input = $node->input() || "??";
		if (! $node->comment()) {
			# ID
			my $ID = $node->var('id');
			$ID = $lines->[$i] if (! defined($ID));

			# FORM
			my $FORM = $input;
			$FORM =~ s/\s+//g;
			$FORM =~ s/&amp;/\&/g;

			# LEMMA
			my $LEMMA = $node->var('lemma') || "_";

			# CPOSTAG and POSTAG
			my $msd = $node->var($tag) || "??";
			my $POSTAG = $node->var($tag) || "??";
			my $CPOSTAG = $node->var($ctag) || "??";
			my $FEATS = "";

			# Special Parole tag filtering
			if ($tag eq "msd") {
				my $msd = my $XPOSTAG = $POSTAG = $CPOSTAG = $node->var($tag);

				# Compute cpostag
				$XPOSTAG =~ s/^(.).*/$1/g;
				$XPOSTAG = "SP" if ($XPOSTAG eq "S");
				$XPOSTAG = "RG" if ($XPOSTAG eq "R");

				# Compute postag
				$CPOSTAG =~ s/^(..).*$/$1/;
				$CPOSTAG = "I" if ($CPOSTAG =~ /^I/);
				$CPOSTAG = "U" if ($CPOSTAG =~ /^U/);

				# FEATS
				$FEATS = conll_msd2features($XPOSTAG, 
					substr($msd, min(length($msd), 2)));
				$FEATS = ($FEATS =~ /^_$/) ? "" : "$FEATS";
			}
			$FEATS = ($FEATS ne "" ? "$FEATS|" : "") . "id=$ID"; 

			# HEAD AND DEPREL
			my $edges = [grep {&$edgefiltersub($_)} @{$node->in()}];
			my ($head, $type) = (0, "ROOT");
			if (scalar(@$edges) >= 1) {
				# More than one primary parent
				if (scalar(@$edges) > 1) {
					# Try to filter out edges ending in '#' -- in the
					# Copenhagen Danish-English treebank, these may
					# indicate dependencies into non-root morphemes
					$edges = [grep {my $s = $_->type(); $s !~ /#$/} @$edges];

					# Check again
					if (scalar(@$edges) > 1) {
						warning("node $i: more than one primary head");
					} else {
						warning("node $i: more than one primary head, but resolved problem by ignoring relations ending with '#'");
					}
				}

				# One primary parent 
				my $edge = $edges->[0];
				$type = $edge->type() || "??";
				$head = $lines->[$edge->out()] || "??";
			}
			my ($HEAD, $DEPREL) = ($head, $type);
			$HEAD = "0" if ($head eq "??");

			# PHEAD and PDEPREL
			my ($PHEAD, $PDEPREL) = ("_", "_");

			# Print head and type
			printf CONLL "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
				$lines->[$i], $FORM,
				($LEMMA || "_"),
				($CPOSTAG || "_"), ($POSTAG || "_"), ($FEATS || "_"),
				($HEAD || "0"), ($DEPREL || "_"), $PHEAD, $PDEPREL;
			$prevblank = 0;
		} 

		if ($boundaries->{$i} && $prevblank == 0) {
			print CONLL "\n";
			$prevblank = 1;
		}
	}

	# Close file
	close("CONLL");
	print "saved conll-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}

sub conll_msd2features {
	my ($CPOSTAG, $featstr) = @_;
	my @featlist = ();
	my $position = 3;
	my $feat = '';

	# Interpret feature string $s
	while ($featstr) {
		# Extract feature string
		if ($featstr =~ /^\[/) {
			my $i = index($featstr, ']');
			$feat = substr($featstr, 1, $i);
			$featstr = substr($featstr, $i+1);
		} else {
			$feat = substr($featstr, 0, 1);
			$featstr = substr($featstr, 1);
		}

		# '=' means that feature is in general not defined for this
		# coarse pos; '-' means that it not defined for this
		# particular fine pos

		if ($feat !~ /[-=]/) {
			my $featname = $conll_msd2features_table->{$CPOSTAG}[$position - 3][0];
			my @values = ();
			for (my $i = 0; $i < length($feat); ++$i) {
				my $value = $conll_msd2features_table
						->{$CPOSTAG}[$position-3][1]{substr($feat, $i, 1)};
				push @values, $value
					if ($value);
			}
			my $featval = join("/", @values);
			push @featlist, "$featname=$featval"
				if ($featname);
		}	
		++$position;
	}

	return join("|", @featlist) || "_";	
}


