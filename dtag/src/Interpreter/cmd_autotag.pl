sub cmd_autotag {
	my $self = shift;
	my $graph = shift;
	my $tag = shift;
	my $files = shift || "";
	my $matches = shift || 0;
	#print "autotag: tag=\"$tag\" matches=\"$matches\" files=\"$files\"\n";
	
	# Check that $graph is a dependency graph
	if (! UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		error("no active graph");
		return 1;
	}

	# Turn off autotagger if argument is "-off"
	if ($files =~ /^\s*-off\s*$/) {
		$graph->var('autotagvar', undef);
		return 1;
	} else {
		$graph->var('autotagvar', $tag);
	}

	# Specify matches
	$graph->var('autotagmatches', 
		$matches ? $graph->matches($self) : undef);

	# Set new variable
	$self->cmd_vars($graph, $tag);

	# If first file argument is "-default" and an autotag lexicon already
	# exists, then drop given files
	my $lexicons = $self->var('autotaglex') || {};
	$self->var('autotaglex', $lexicons);
	if (! ($files =~ /^\s*-default\s+/ && defined($lexicons->{$tag}))) {
		$lexicons->{$tag} = $lexicons->{$tag} || {};
		my $lexicon = {};
		$lexicons->{$tag} = $lexicon;

		# Save current graph and viewer
		my $currentgraph = $self->{'graph'};
		$graph->mtime(1);
		my $viewer = $self->var('viewer');
		$self->var('viewer', 0);

		# Create new tag lexicon
		inform("Training autotagger. Please wait.");
		foreach my $file (glob($files)) {
			# Load file
			if ($file =~ /.tag$/) {
				# Graph
				$self->cmd_load_tag($graph, $file);
				my $ngraph = $self->graph();
				$self->{'graph'} = $currentgraph;

				# Train new lexicon for alignment
				for (my $i = 0; $i < $ngraph->size(); ++$i) {
					my $node = $ngraph->node($i);
					my $tagvalue = $node->var($tag);
					$self->cmd_autotag_addkeys($node->input(),
						$tagvalue, $tag, $lexicon);

					my $key = $node->input();
					if (defined($key) && defined($tagvalue)) {
						if (! exists $lexicon->{$key}) {
							$lexicon->{$key} = {};
						}
						$lexicon->{$key}{$tagvalue} += 1;
					}
				}
			}
		}
	}
	
	# Find last tagged position
	my $pos = -1;
	for (my $i = $graph->size() - 1; $i >= 0; --$i) {
		my $node = $graph->node($i);
		if (defined($node->var($tag))) {
			$pos = $i + 1;
			last;
		}
	}

	# Print help
	print "Autotagging commands:\n";
	print "    \"<\$label\": set label for current word with replacement of #\$n shortcuts\n";
	print "    \"\$pos<\$label\": set label for word \$pos with replacement of #\$n shortcuts\n";
	print "    \"autotag -off\": stop autotagger\n";
	print "    \"autotag -pos \$pos\": move to word \$pos\n";
	print "    \"autotag -offset \$pos\": set offset to \$pos\n";

	# Autotag edges
	$graph->var('autotagpos', $pos - 1);
	$self->var('viewer', $viewer);
	$self->cmd_autotag_next($graph);

	# Return
	return 1;
}

sub cmd_autotag_addkey {
	my ($self, $key, $value, $lexicon) = @_;
	if (defined($key) && defined($value)) {
		if (! exists $lexicon->{$key}) {
			$lexicon->{$key} = {};
		}
		$lexicon->{$key}{$value} += 1;
	}
}	


sub cmd_autotag_addkeys {
	my ($self, $key, $value, $feature, $lexicon) = @_;
	$lexicon = $self->var('autotaglex')->{$feature}
		if (! defined($lexicon));
	$self->cmd_autotag_addkey($key, $value, $lexicon);
	$self->cmd_autotag_addkey("_lc_:" . lc($key), $value, $lexicon);
}	

sub cmd_autotag_lookup {
	# Parameters
	my ($self, $key, $feature, $lexicon) = @_;
	$lexicon = $self->var('autotaglex')->{$feature}
		if (! defined($lexicon));

	# Lookup
	my $matches = {};
	my $hashes = [$lexicon->{$key}, $lexicon->{"_lc_:" . lc($key)}];
	foreach my $hash (@$hashes) {
		if (defined($hash)) {
			foreach my $key (keys(%$hash)) {
				$matches->{$key} += $hash->{$key};
			}
		}
	}

	# Return matches
	return($matches);
}

sub autotag_off {
	my ($self, $graph) = @_;
	$graph->var('autotagvar', undef);
}
