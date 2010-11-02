=item $graph->words($i1, $i2, $separator) = $text

=cut

my $digits = "\x{2070}\x{00B9}\x{00B2}\x{00B3}\x{2074}\x{2075}\x{2076}\x{2077}\x{2078}\x{2079}";

sub words {
	my $self = shift;
	my $i1 = shift;
	my $i2 = shift;
	my $sep = shift || "";
	my $number = shift;
	my $unicode = shift;
	$number = 1 if (! defined($number));

	# Ensure $i1 and $i2 are set
	$i1 = 0 if (! defined($i1));
	$i2 = $self->size()-1 if (! defined($i2));
	$i1 = max($i1, 0);
	$i2 = min($i2, $self->size()-1);

	# Compute text
	my $text = "";
	my $size = $self->size();
	my $first = 1;
	my $lastten = -1000;
	for (my $i = $i1; $i <= $i2; ++$i) {
		# Add text
		my $node = $self->node($i);
		if (! $node->comment()) {
			$text .= $sep if (! $first);
			if ($unicode) {
				if ($i - $lastten >= 10) {
					# Print entire text
					$text .= superscript($i - $self->offset());
					$lastten = $i - ($i % 10);
				} elsif ($number) {
					# Print only last digit
					my $sup = superscript($i -$self->offset());
					$text .= substr($sup, length($sup) - 1);
				}
			}
			
			if (Encode::decode_utf8($node->input())) {
				$text .=  Encode::decode_utf8($node->input());
			} else {
				$text .= $node->input();
			}
			$first = 0;
		}
	}

	# Return text
	return $text;
}


sub superscript {
	my $n = "" . shift;

	my $s = "";
	for (my $i = 0; $i < length($n); ++$i) {
		my $digit = substr($n, $i, 1);
		$s .= substr($digits, 0 + $digit, 1);
	}

	return $s;
}
