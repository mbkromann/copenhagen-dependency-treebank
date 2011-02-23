=item $graph->postscript() = $postscript

Return PostScript representation $postscript for graph.

=cut


sub addps {
	my $s = shift;
	while (@_) {
		my $t = shift;
		#print($t);
		$s .= $t;
	}
	return($s);
}

sub postscript {
	my $self = shift;
	my $interpreter = shift;

	# Variables
	my $N = 0;					# number of words
	my $E = 0;					# number of edges
	my $nodes = { };			# nodes in graph
	my $streams = { };			# streams in graph
	my $labels = { };			# labels in graph and their position
	my $ps = addps("", "% Words and edges\n");
	$self->{'psstyles'} = {};	# reset compiled styles
	$self->{'psstyleno'} = 0;	# number of psstyles

	# Find hash with matched nodes
	my $matches = $self->matches($interpreter);

	# Find layout values, with defaults
	my $sub0 = sub { return 0 };
	my $subL = sub { return [] };
	my $stream = $self->layout($interpreter, 'stream') || $sub0;
	my $nstyles = $self->layout($interpreter, 'nstyles') || $subL;
	my $estyles = $self->layout($interpreter, 'estyles') || $subL;
	my $nhide = $self->layout($interpreter, 'nhide') || $sub0;
	my $ehide = $self->layout($interpreter, 'ehide') || $sub0;
	my $pos = $self->layout($interpreter, 'pos') || $sub0;

	# Find possible variables to include in the graph
	my $regexps = [split(/\|/, 
		$self->layout($interpreter, 'vars') || "/stream:.*/|msd|gloss")];
	my @newvars = ();
	foreach my $var (keys(%{$self->vars()})) {
		push @newvars, $var
			if (regexp_match($regexps, $var));
	}
	#print "vars: " . join(" ", @newvars) . "\n";

	# Find nodes, streams, and variables to include in graph using
	# nhide, $imin, and $imax, and number words consecutively from 0
	my $imin = max($self->var('imin'), 0);
	my $imax = min($self->var('imax'), $self->size()-1);
	$imax = $self->size() if ($imax < 0);
	for (my $i = $imin; $i <= $imax; ++$i) {
		my $node = $self->node($i);
		if ($self->node($i) && (! &$nhide($self, $self->node($i)))
			&& ((! defined($self->include())) || $self->include()->{$i})
			&& ((! defined($self->exclude())) || ! $self->exclude()->{$i})) {
			# Node $i is printed in the graph
			$nodes->{$i} = $N++;

			# Find stream associated with word
			$streams->{&$stream($self, $node) || 0} = 1;

			# Try to find values for missing newvars
			if (@newvars) {
				my @newvars2 = ();
				foreach my $var (@newvars) {
					if (defined($node->var($var))) {
						$labels->{$var} = regexp_match($regexps, $var);
					} else {
						push @newvars2, $var;
					}
				}
				@newvars = @newvars2;
			}
		}

		# Abort if requested
		last() if ($interpreter->abort());
	}

	# Exit if no nodes
	return undef if (! $N);

	# Add position and streams to possible labels
	my $match = regexp_match($regexps, '_position');
	$labels->{'_position'} = $match if ($match);
	#print "_position match: $match\n";
	foreach my $s (keys(%$streams)) {
		$match = regexp_match($regexps, "stream:$s");
		$labels->{"stream:$s"} = $match if ($match);
	}

	# Sort labels and check that there is at least one label
	my $L = 0;
	my @sorted = ();
	foreach my $l (sort {($labels->{$a} <=> $labels->{$b}) 
							|| ($a cmp $b)} keys(%$labels)) {
		$labels->{$l} = $L++;
		push @sorted, $l;
	}
	#print "sorted: " . join(" ", @sorted) . "\n";
	return DTAG::Interpreter::error("illegal number of variables: $L") 
		if ($L == 0);

	# Create alignments 
	my $forced_edget = {};
	my $forced_edgeb = {};
	my $alignments = "% Alignments\n/alignments [\n";
	foreach my $inalign (sort(keys(%{$self->{'inalign'}}))) {
		# Interpret $inalign edge
		my ($from, $to, $label) = split(/\s+/, $inalign);
		$label = "" if (! defined($label));
		my $keep = 1;
		my @fromlist = map {my $inode = $nodes->{$_}; 
			defined($inode) ? $inode : ($keep = 0)}
				split(/\+/, $from);
		my @tolist = map {my $inode = $nodes->{$_}; 
			defined($inode) ? $inode : ($keep = 0)}
				split(/\+/, $to);

		# Create PostScript code
		$alignments .= "\t[" 
			. ($#fromlist == 0 ? $fromlist[0] : 
				"[" . join(" ", @fromlist) . "]")
			. " "
			. ($#tolist == 0 ? $tolist[0] : 
				"[" . join(" ", @tolist) . "]") 
			. " ($label)]\n";

		# From nodes have forced edget edges, to nodes have forced edgeb edges
		map {$forced_edget->{$_} = 1} @fromlist;
		map {$forced_edgeb->{$_} = 1} @tolist;
	}
	$alignments .= "] def\n\n";

	# Print words and edges
	foreach my $n (sort {$a <=> $b} keys(%$nodes)) {
		my $node = $self->node($n);

		# Print word
		my $s = &$stream($self, $node) || 0;
		my $val = "";
		foreach my $lbl (@sorted) {
			# Find value
			if ($lbl =~ /^stream:.*$/) {
				$val = ($lbl eq "stream:$s") 
					?  $node->input() : "";
			} elsif ($lbl eq '_position') {
				my $rpos = $n - $self->offset();
				$val = ($self->offset() && $rpos >= 0) 
					? "+$rpos" : "$rpos";
			} else {
				$val = $self->reformat($interpreter, $lbl, $node->var($lbl),
					$self, $n);
			}

			# Find layout ID
			my $stylelist = &$nstyles($self, $node, $lbl);
			$stylelist = [$stylelist] 
				if (!  UNIVERSAL::isa($stylelist, "ARRAY"));

			push @$stylelist, 'match' if ($matches->{$n});
			my $layout = $self->psstyle($interpreter, 'label',  $stylelist);

			# Produce PostScript string
			$ps = addps($ps, psstr($val) . $layout . " ");
		}
		$ps = addps($ps, "word\n");

		# Print in-edges of word, if out-word is in $nodes
		my $bottom = 0;
		foreach my $e (@{$node->in()}) {
			if (defined($nodes->{$e->out()}) && ! (&$ehide($self, $e))) {
				# Calculate edge layouts
				my $type = $e->type();
				my $alayout = $self->psstyle($interpreter, 'arc', 
					&$estyles($self, $e));
				my $llayout = $self->psstyle($interpreter, 'arclabel', 
					&$estyles($self, $e));
				$llayout = 0 if ($alayout && ! $llayout);

				$ps = addps($ps, $nodes->{$e->in()} . " " 
					 . $nodes->{$e->out()} . " "
					 . psstr($e->type())
					 . $llayout . $alayout . " ");

				# Find out whether the edge is top or bottom
				if (&$pos($self, $e)) {
					# Bottom edge (unless forced top)
					$ps = addps($ps, 
						$forced_edget->{$e->in()} ? "edget\n" : "edgeb\n");
				} else {
					# Top edge (unless forced bottom)
					$ps = addps($ps,
						$forced_edgeb->{$e->in()} ? "edgeb\n" : "edget\n");
				} 

				# Increment edge counter
				++$E;
			}
		}

		# Abort if requested
		last() if ($interpreter->abort());
	}

	# Print fixations
	my $fixations = "";
	my $fnodes;
	my $lastattrg;
	my $nodeht = {};
	my $nodehb = {};
	my $maxht = 0;
	my $maxhb = 0;
	my $maxdur = 0;
	my $mindur = 1e100;
	my $fixbarstyle = $self->psstyle($interpreter, 'label',  ['fixation']) || 0;
	my $fixarcstyle = $self->psstyle($interpreter, 'arc',  ['fixation']) || 0;
	my $fixbarlabelstyle = $self->psstyle($interpreter, 'arclabel',  ['fixation']) || 0;
	foreach my $fixlist (@{$self->var("fixations") || []}) {
		my ($fixgraph, $attrd, $attrg, $attrf, $ontop, $imin, $imax) = @$fixlist;
		#print "fixgraph=$fixgraph attrg=$attrg attrf=$attrf attrd=$attrd ontop=$ontop\n";
		$fnodes = $self->nodes_with_valid_attr($attrg) 
			if (! (defined($fnodes) && defined($lastattrg) && $lastattrg eq $attrg));
		#print "fnodes: " . DTAG::Interpreter::dumper($fnodes) . "\n";
		my $fsequence = [];
		my $heights = $ontop ? $nodeht : $nodehb;
		my $eedgecmd = $ontop ? " eedget" : " eedgeb";
		for (my $i = $imin; $i < $fixgraph->size() && $i <= $imax; ++$i) {
			my $fnode = $fixgraph->node($i);
			my $flink = $fnode->var($attrf);
			#print "i=$i fnode=$fnode flink=$flink\n";

			# Add fixation to $fsequence
			if (defined($flink)) {
				my $gnode = $self->find_first_node_before_value($attrg, $flink, $fnodes);
				my $psnode = defined($gnode) ? $nodes->{$gnode} : undef;
				#print "gnode=$gnode psnode=$psnode\n";
				my $dur = $fnode->var($attrd) || 0;
				$dur = $dur <= 0 ? 0.0000001 : log($dur);
				if (defined($psnode)) {
					my $nodeh = $heights->{$psnode} || 0;
					$heights->{$psnode} = $nodeh + 1;
					push @$fsequence, [$psnode, $nodeh, $dur, $i];
					#print "  [$psnode, $nodeh, $dur]\n";
					if ($ontop) {
						$maxht = max($maxht, $nodeh);
					} else {
						$maxhb = max($maxhb, $nodeh);
					}
					$maxdur = max($maxdur, $dur);
					$mindur = min($mindur, $dur);
				} else { 
					$flink = undef;
				}
			} 

			# Print $fsequence and reset
			if (@$fsequence && ($i == min($imax, $fixgraph->size()-1) || ! defined($flink))) {
				$E += scalar(@$fsequence);
				for (my $j = 0; $j <= $#$fsequence; ++$j) {
					my $j0 = max(0, $j-1);
					my ($f1, $h1, $d1) = @{$fsequence->[max(0, $j-1)]};
					my ($f2, $h2, $d2, $i) = @{$fsequence->[$j]};
					$fixations .= "$f2 $f1 ($i) $fixbarstyle $fixarcstyle "
						. "$d2 $d1 $h2 $h1 $fixbarlabelstyle $eedgecmd\n";
				}	
				$fixations .= "\n";
			}	
		}
	}
	#print "fixations=$fixations\n";
	my $fixationsetup = "";
	if ($fixations) {
		my $mindurw = 1;
		my $maxdurw = 20;
		my $dEsw = $maxdur > $mindur ? ($maxdurw - $mindurw) / ($maxdur - $mindur) : 1;
		my $dEow = $maxdurw - $dEsw * $maxdur;

		printf("using width = %.4g + %.4g * ln(dur) with durations %.4g..%.4g, widths $mindurw..$maxdurw\n",
			$dEow, $dEsw, exp($mindur), exp($maxdur));
		$fixationsetup = "% Fixation setup\n"
			. "/Emaxht $maxht def\n"
			. "/Emaxhb $maxhb def\n"
			. "/dEsw $dEsw def\n"
			. "/dEow $dEow def\n\n";
	}

	# Produce PostScript styles
	my $titlestyle = $self->psstyle($interpreter, 'label',  ['title']) || 0;
	my $pslayout = "/formats [\n";
	foreach my $pstyle (sort 
			{$self->{'psstyles'}{$a} <=> $self->{'psstyles'}{$b}}
			keys(%{$self->{'psstyles'}})) {
		$pslayout .= "\t{$pstyle}\n";
	}
	$pslayout .= "] def\n\n";

	# Find prologue
	my $pssetup = $self->layout($interpreter, 'pssetup') || "";

	# Print setup
	my $title = $self->var('title') || " ";
	$title =~ s/\(/\\\(/g;
	$title =~ s/\)/\\\)/g;
	$ps = $psheader->{'arcs'} 
		. "% General setup\n" 
		. $pssetup . "\n\n"
		. "% Graph setup\n" 
		. "/title {($title) $titlestyle} def\n\n"
		. "$fixationsetup"
		. "$L $N $E setup\n" 
		. $pslayout
		. $ps . "\n"
		. $fixations . "\n"
		. $alignments 
		. $pstrailer->{'arcs'};

	# Return string
	return Encode::encode("iso-8859-1", $ps);
}

sub regexp_match {
	my $regexps = shift;
	my $s = shift;
	$s = "" if (! defined($s));

	my $i = 0;
	foreach my $regexp (@$regexps) {
		++$i;
		if ($regexp =~ /^\/.*\/$/) {
			return $i if (eval("\$s =~ $regexp"));
		} else {
			return $i if ($s eq $regexp);
		}
	}
	return 0;
}

sub psstr {
	my $input = shift;
	$input = "" if (! defined($input));
	$input =~ s/\)/\\\)/;
	$input =~ s/\(/\\\(/;
	$input =~ s/\&gt;/>/;
	$input =~ s/\&lt;/</;

	return "(" . 
		$input
		#	Encode::encode("iso-8859-1", $input) 
		. ")";
}

