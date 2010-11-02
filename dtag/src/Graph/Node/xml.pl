=item $node->xml($graph, $displace) = $xml

Return xml-representation $xml of node $node within graph $graph,
where $displace is the position of the node in the file. 

=cut

sub xml {
	my $self = shift;
	my $graph = shift;
	my $displace = shift || 0;
	my $noquote = shift || 0;

	sub emph {
		my $text = shift;
		return colored($text, 'bold red') if ($color);
		return $text;
	}

	sub emph_input {
		my $text = shift;

		$text =~ s/</&lt;/g;
		$text =~ s/>/&gt;/g;

		return colored($text, 'bold blue') if ($color);
		return $text;
	}	

	# Node represents a comment, to be printed verbatim
	return $self->input() if ($self->comment());

	# XML format with variable-value pairs
	my $string = "<" . $self->type() . "";

	# Variable-value pairs
	foreach my $var (sort(keys %$self)) {
		if (exists $graph->vars()->{$var}) {
			my $value = $self->var($var);
			$value = ref($value) ? $self->varstr($var) : "\"$value\"";
			$value = "\"\"" if ("$value" eq "");
			$string .= " $var=" . emph($noquote ? $value : $graph->xml_quote($value)) . "";
		}
	}

	# In-edges
	my @edges = ();
	foreach my $e (@{$self->in()}) {
		push @edges, ($displace + $e->out()) . ":" .  ($noquote ? $e->type() : $graph->xml_quote($e->type()))
			unless ($e->var('ignore'));
	}
	$string .= " in=\"" . emph(join("|", @edges)) . "\"";

	# Out-edges
	@edges = ();
	foreach my $e (@{$self->out()}) {
		push @edges, ($displace + $e->in()) . ":" . ($noquote ? $e->type() : $graph->xml_quote($e->type()))
			unless ($e->var('ignore'));
	}
	$string .= " out=\"" . emph(join("|", @edges)) . "\"";

	# Return value
	$string .= ">" . emph_input($self->input()) . "</" . $self->type() . ">";
	return $string;
}

