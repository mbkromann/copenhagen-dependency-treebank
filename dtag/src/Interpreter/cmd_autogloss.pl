# Specify tag feature

sub cmd_autogloss {
	my $self = shift;
	my $graph = shift;
	my $afile = shift || "";
	my $mapfiles = shift || "";

	# Create atag graph, either dummy or loaded graph
	my $agraph = DTAG::Alignment->new($self);
	my $key = "";
	my $ograph = undef;
	if ($afile) {
		# Load atag file
		$self->cmd_load_atag($graph, $afile);
		$agraph = $self->graph();

		# Determine key
		foreach my $k (keys(%{$agraph->graphs()})) {
			if ($agraph->graph($k)->file() eq $graph->file()) {
				$key = $k;
			} else {
				$ograph = $agraph->graph($k);
			}
		}


		# Determine whether graph was found in alignment
		if (! $key) {
			return error("Graph not found in alignment");
		}
	}

	# Load all other gloss maps
	my $maps = [];
	foreach my $mapfile (split(/\s+/, $mapfiles)) {
		if (-f $mapfile) {
			my $map = {};
			push @$maps, $map;
			open(IFS, "<$mapfile") 
				|| return error("Error opening mapfile $mapfile");
			while (my $line = <IFS>) {
				chomp($line);
				my ($key, $value) = split(/\t/, $line);
				$map->{$key} = $value;
			}
			close(IFS);
		} else {
			return error("Non-existent mapfile $mapfile!");
		}
	}

	# Process all nodes in graph
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $N = $graph->node($i);
		my $gloss = "";
		if (! $N->comment()) {
			# Lookup gloss in alignment
			my @aedges = grep {$_->type() eq "" && $_->inkey() ne $_->outkey()} 
				@{$agraph->node($key, $i) || []};
			if (@aedges) {
				if ($aedges[0]->outkey() eq $key
					&& scalar(@{$aedges[0]->outArray()}) == 1) {
					$gloss = join("_", 
						map {($ograph->node($_) ? $ograph->node($_)->input() : "") 
							|| ""}
							@{$aedges[0]->inArray()});
				} elsif ($aedges[0]->inkey() eq $key &&
						scalar(@{$aedges[0]->inArray()}) == 1) {
					$gloss = join("_", 
						map {($ograph->node($_) ? $ograph->node($_)->input()
							: "") 
							|| ""}
							@{$aedges[0]->outArray()});
				}
			}

			# Alternatively, lookup gloss in map files (first match
			# is used)
			my $word = $N->input();
			my $lcword = lc($word);
			my $lemma = $N->var('lemma') || undef;
			if (! $gloss) {
				foreach my $token ($word, $lcword, $lemma) {
					foreach my $map (@$maps) {
						if ($map->{$token}) {
							$gloss = $map->{$token};
							last();
						}
					}
					last() if ($gloss);
				}
			}

			# Alternatively, use source string
			$gloss = $word if (! $gloss);

			# Save gloss in tag file
			$gloss =~ s/ /_/g;
			$gloss =~ s/"/&quot;/g;
			$N->var('gloss', $gloss);
		}
	}
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	$self->cmd_vars($graph, 'gloss');

	# Return
	return 1;
}
