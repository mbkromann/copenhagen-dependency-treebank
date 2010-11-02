sub cmd_style {
	my $self = shift;
	my $graph = shift;
	my $style = shift;
	my $opt = shift || "";
	$opt .= " " if ($opt ne "");

	# Clear styles
	my $sparent = $self;
	$sparent = $graph if ($graph && $opt =~ s/^-graph\s+//);
	if ($style =~ /^-clear\s*$/) {
		$sparent->{'styles'} = {};
		return 1;
	}

	# PostScript equivalents
	my $color = { 
		'black' 	=> '0 setgray',
		'white' 	=> '1 setgray', 
		'gray'  	=> '0.5 setgray',
		'gray10'	=> '0.1 setgray',
		'gray20'	=> '0.2 setgray',
		'gray30'	=> '0.3 setgray',
		'gray40'	=> '0.4 setgray',
		'gray50'	=> '0.5 setgray',
		'gray60'	=> '0.6 setgray',
		'gray70'	=> '0.7 setgray',
		'gray80'	=> '0.8 setgray',
		'gray90'	=> '0.9 setgray',
		'red'   	=> '1 0 0 setrgbcolor',
		'green' 	=> '0 1 0 setrgbcolor',
		'blue'  	=> '0 0 1 setrgbcolor',
		'cyan'  	=> '0 1 1 setrgbcolor',
		'magenta'	=> '1 0 1 setrgbcolor',
		'yellow' 	=> '1 1 0 setrgbcolor',
		'darkred'	=> '0.5 0 0 setrgbcolor',
		'darkgreen'	=> '0 0.5 0 setrgbcolor',
		'darkblue'	=> '0 0 0.5 setrgbcolor',
		'lightred'	=> '1 0.5 0.5 setrgbcolor',
		'lightgreen'	=> '0.5 1 0.5 setrgbcolor',
		'lightblue'	=> '0.5 0.5 1 setrgbcolor',
	};
	my $dash = {
		'none' 		=> '', 'dash' 		=> '[4] 0 setdash',
		'dot'		=> '[2] 0 setdash',
	};
	my $fonttype = {
		'roman'		=> '',
		'bold'		=> '1 setfontstyle setupfont',
		'italic'	=> '2 setfontstyle setupfont',
		'bolditalic'=> '3 setfontstyle setupfont',
	};

	# Reset style $style
	$sparent->{'styles'}{$style}{'label'} = "";
	$sparent->{'styles'}{$style}{'arclabel'} = "";
	$sparent->{'styles'}{$style}{'arc'} = "";

	# Process options
	my $context = 'label';
	while ($opt) {
		if ($opt =~ s/^-label\s+//) {
			# -label
			$context = 'label';
		} elsif ($opt =~ s/^-arclabel\s+//) {
			# -arclabel
			$context = 'arclabel';
		} elsif ($opt =~ s/^-arc\s+//) {
			# -arc
			$context = 'arc';
		} elsif ($opt =~ s/^-ps\s+\"([^"]+)\"\s+// 
				|| $opt =~ s/^-ps\s+\'([^']+)\'\s+//) {
			# -ps $postscript
			$sparent->{'styles'}{$style}{$context} 
				.= $1 . " ";
		} elsif ($opt =~ s/^-color\s+(\S+)\s+//) {
			# -color $color
			my $s = $1;
			my $col = "";
			if ($color->{$s}) {
				$col = $color->{$s};
			} elsif ($s =~ /^gray\((1|1\.0*|0|0\.[0-9]*)\)$/) {
				$col = "$1 setgray";
			} elsif ($s =~ /^rgb\((1|1\.0*|0|0\.[0-9]*),(1|1\.0*|0|0\.[0-9]*),(1|1\.0*|0|0\.[0-9]*)\)$/) {
				$col = "$1 $2 $3 setrgbcolor";
			} 
			$sparent->{'styles'}{$style}{$context} 
				.= $col . " ";
		} elsif ($context ne "arc" && $opt =~ s/^-fonttype\s+(\S+)\s+//) {
			# -fonttype $fonttype
			$sparent->{'styles'}{$style}{$context} 
				.= ($fonttype->{$1} || "") . " ";
		} elsif ($context eq "arc" && $opt =~ s/^-dash\s+(\S+)\s+//) {
			# -dash $dash
			$sparent->{'styles'}{$style}{$context} 
				.= ($dash->{$1} || "") . " ";
		} elsif ($opt =~ s/^(\S+)?\s+//) {
			error("Illegal style option: $1");
		} else {
			$opt =~ s/^\s*$//;
		}
	}

	# Return
	return 1;
}
