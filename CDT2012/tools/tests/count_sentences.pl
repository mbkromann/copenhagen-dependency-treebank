# check sentence alignments for all files in current directory
$t2dir = shift;

@f = `ls [0-9][0-9][0-9][0-9]-[a-z][a-z].tag`;

for $f (@f) {
    chomp $f;
    if ($f =~ /([0-9][0-9][0-9][0-9])-.*\.tag/) {
	$k = $1;
	$f2 = $k . "-en.tag";
	open(F1,$f) or die;
	open(F2,"<$t2dir/$f2") or die;
	$t1cnt = $t2cnt = 0;
	while (<F1>) {
	    $t1cnt++ if (/\<s\>/);
	}
	while (<F2>) {
	    $t2cnt++ if (/\<s\>/);
	}
	if ($t1cnt == $t2cnt) {
	    print STDERR "$f and $f2 both $t1cnt sentences\n";
	} else {
	    print "ERROR: $f $t1cnt sentences $f2 $t2cnt sentences\n";
	}
    }
}


