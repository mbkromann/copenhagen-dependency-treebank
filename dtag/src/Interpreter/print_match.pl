sub print_match {
	my $self = shift;
	my $match = shift;
	my $file = shift;
	my $binding = shift;
	my $options = shift;
	my @vars = sort(grep {substr($_, 0, 1) eq '$'} keys(%$binding));

	# Find graph index from graph ID
	if ($file =~ /^\[G[0-9]*\]$/) {
		my $index = $self->gid2index($file) + 1;
		$file = "G$index";
	}

	# Find goto position
	my $position = "1e100";
	grep {
		my $n = $binding->{$_};
		$position = $n if ($n =~ /^[0-9]+$/ && $n < $position)
	} @vars;
	$position = max(0, $position - ($self->var('goto_context') || 0));

	# Print match
	my $string = "";
	if (! $options->{'nomatch'}) {
		my $varstr = join(", ", map {
				$self->varkey($binding, $_) . $binding->{$_}
			} (@vars));
		$string .=	sprintf '%sM%-3d match at %s:%s %s' . "\n",
				(($self->{'match'} || 0) == $match ? "*" : " "),
				$match,
				$file,
				$position,
				"(" . join(", ", @vars) . ")"
					. " = (" . $varstr  . ")";
	}

	# Print key and text
	if ($binding->{'key'} && ! $options->{'nokey'}) {
		$string .= 	"      key: " . $binding->{'key'} ."\n";
	}
	if ($binding->{'text'} && ! $options->{'notext'}) {
		$string .= 	"      text: " . $binding->{'text'} ."\n";
	}

	# Return string
	return $string;
}


