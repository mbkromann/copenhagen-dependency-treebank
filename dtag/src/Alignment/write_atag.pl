sub write_atag {
	my $self = shift;
	my $atag = "<DTAGalign>\n";
	
	# Print <alignFile> tags
	my $sign = {};
	foreach my $key (sort(keys(%{$self->{'graphs'}}))) {
		my $file = $self->{'graphs'}{$key}->file();
		$atag .= 
			"<alignFile key=\"$key\" href=\"$file\" sign=\"_input\"/>\n";
		$sign->{$key} = "_input";
	}

	# Print <align> tags
	foreach my $e (@{$self->{'edges'}}) {
		my $inkey = $e->inkey();
		my $outkey = $e->outkey();
		my $type = $e->type();
		my $ingraph = $self->{'graphs'}{$inkey};
		my $outgraph = $self->{'graphs'}{$outkey};

		$atag .= 
			'<align out="'
					. join(" ", map {$outkey . $_} @{$e->outArray()})
				. '" type="'
					. (defined($type) ? $type : "")
				. '" in="'
					. join(" ", map {$inkey . $_} @{$e->inArray()})
				. '" creator="'
					. $e->creator()
				. '" insign="'
					. signature($ingraph, $e->inArray(), $sign->{$inkey})
				. '" outsign="'
					. signature($outgraph, $e->outArray(), $sign->{$outkey})
				. '"'
				#. vars2xml($e->vars()) 
				. "/>\n";
	}

	# Print <compound> tags
	my $compounds = $self->{'compounds'};
	foreach my $c (sort(keys(%$compounds))) {
		$atag .= '<compound node="' . $c . '">' . $compounds->{$c}
			. "</compound>\n";
	}

	# Print end tag
	$atag .= "</DTAGalign>\n";

	# Return 
	return $atag;
}

sub vars2xml {
	my $vars;
	return "";
}

sub signature {
	my $graph = shift;
	my $nodes = shift;
	my $var = shift;

	my $signature = "";
	my $s = "";
	return join(" ",
		map {
			my $nodeobj = $graph->node($_);
			my $val = $nodeobj ? $nodeobj->var($var) || "÷" : "÷";
			$val = "$val" || "÷";
			$val =~ s/ /\&nbsp;/g;
			$val =~ s/"/&quot;/g;
			$val;
		} @$nodes);
}

