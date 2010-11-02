sub xml_quote {
	my $self = shift;
	my $string = shift;
	$string =~ s/\&/\&amp;/g;
	$string =~ s/</\&lt;/g;
	$string =~ s/>/\&gt;/g;
	$string =~ s/(.)"(.)/$1\&22;$2/g;
	$string =~ s/\|/\&7c;/g;
	$string =~ s/:/\&3a;/g;
	return $string;
}
