sub strip_relation {
	my $type = shift;
    $type =~ s/^[:;+]//g;
	$type =~ s/^[¹²³^]+//g;
	$type =~ s/^\¤//g;
	$type =~ s/[¹²³^]+$//g;
	$type =~ s/\#$//g;
	$type =~ s/^@//g;
	$type =~ s/\/.*$//g;
	$type =~ s/\*//g;
	$type =~ s/[()]//g;
	$type =~ s/\/ATTR[0-9]+//g;
	return $type;
}

