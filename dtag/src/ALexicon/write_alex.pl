sub write_alex {
	my $self = shift;
	my $sublexicons = shift;
	my $noheader = shift;

	my $s;
	
	# Write header
	if (! $noheader) {
		# Header
		$s = '<DTAGalex lang1="' . $self->lang1() 
			. '" lang2="' .  $self->lang2() . "\">\n";

		# Write sublexicons
		if ($sublexicons) {
			foreach my $sublex (@{$self->sublexicons()}) {
				$s .= "<sublex file=\"" . 
					($sublex->file() || "") . "\"/>\n";
			}
		}
	}

	# Write lexical entries
	my $alex_list = $self->alex();
	for (my $id = 0; $id < scalar(@$alex_list); ++$id) {
		my $alex = $alex_list->[$id];
		if ($alex) {
			$s .= "<alex pos=\"" . $alex->pos()
				. "\" neg=\"" . $alex->neg()
				. "\" out=\"" . seq2str($alex->out())
				. "\" type=\"" . $alex->type()
				. "\" in=\"" . seq2str($alex->in())
				. "\"/>\n";
		}
	}

	# Write gap probabilities
	my $gaps = $self->{'gaps'};
	foreach my $gap (sort(keys(%$gaps))) {
		my $gaplist = $self->gaps($gap);
		for (my $g = 1; $g < scalar(@$gaplist); ++$g) {
			my $pos = $gaplist->[$g] || 0;
			$s .= "<gap pos=\"$pos\" type=\"$gap\" width=\"$g\"/>\n"
				if ($pos > 0);
		}
	}

	# Write entries from sublexicons
	if (! $sublexicons) {
		foreach my $sublexicon (@{$self->sublexicons()}) {
			$s .= "<!--sublexicon: \"" . ($sublexicon->file() || "") .  "\"-->\n";
			$s .= $sublexicon->write_alex(0, 1);
		}
	}

	# Write end tag
	if (! $noheader) {
		$s .= "</DTAGalex>\n";
	}

	# Return string
	return $s;
}

sub seq2str {
	my $list = shift;
	my $str = join(" ",
		map {defined($_) ? $_ : "*"} @$list);
	
	# Replace " with &quot;
	$str =~ s/"/&quot;/g;

	# Return
	return $str;
}

