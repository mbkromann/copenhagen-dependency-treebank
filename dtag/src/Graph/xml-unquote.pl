sub xml_unquote {
	my $self = shift;
	my $string = shift;
	$string =~ s/\&lt;/</g;
	$string =~ s/\&gt;/>/g;
	$string =~ s/\&22;/"/g;
	$string =~ s/\&7c;/|/g;
	$string =~ s/\&3a;/:/g;
	$string =~ s/\&amp;/\&/g;
	return $string;
}
