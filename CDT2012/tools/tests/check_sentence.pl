$tag1 = shift;
$tag2 = shift;
$align = shift;
open(T1,$tag1) or die;
open(T2,$tag2) or die;
open(AL,$align) or die;

while (<T1>) {
    chomp;
    push @t1, $_;
}

while (<T2>) {
    chomp;
    push @t2, $_;
}
while (<AL>) {
    chomp;
    if (/out=\"a([0-9]+)\" .* in=\"b([0-9]+)[^0-9]/) {
	$al[$1] = $2;
    }
}

for ($i = 0; $i <@t1; $i++ ) {
    if ($t1[$i] =~ /\<s\>/) {
	$tot++;
	$inc = 0;
	if (exists($al[$i+1])) {
	    $inc = 1;
	} elsif (exists($al[$i+2])) {
	    $inc = 2;
	} elsif (exists($al[$i+3])) {
	    $inc = 3;
	}
	if ($inc) {
	    $t2_s = $al[$i+$inc] - $inc;
	    if ($t2[$t2_s] =~ /\<s\>/) {
		print STDERR "$i:matching s\n";
		$match++;

	    } else {
		print "    $i:NO matching s for $t1[$i]\n";
	    }
	} else {
	    print "    $i:NO alignment directly after $t1[$i]\n";
	}
    }
}

print "S_ALIGN $tag1: $match out of $tot matching sentences\n";



