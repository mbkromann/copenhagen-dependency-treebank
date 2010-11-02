=item dumpstr($object) = $string

Return string representation of object.

=cut

sub dumpstr {
	my $str = Dumper(shift);
	$str =~ s/^.*=\s*(.*)\s*;\s*$/$1/g;
	if ($str =~ /^["'].*["']$/g) {
		# Normal string: convert to double-quoted string
		$str =~ s/"/&quot;/g;
		$str =~ s/^'(.*)'$/"$1"/g;
	}

	$str =~ s/^([^"'].*)$/`$1`/g;
	return $str;
}
