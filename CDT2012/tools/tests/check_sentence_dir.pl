# check sentence alignments for all files in current directory
$t2dir = shift;
$aldir = shift;
$tools = "~/cbs_login1/home/dh/cdt/CDT2012/tools";
@f = `ls [0-9][0-9][0-9][0-9]-da.tag`;

for $f (@f) {
    if ($f =~ /([0-9][0-9][0-9][0-9])-.*\.tag/) {
	$k = $1;
	$f1 = $k . "-da.tag"; $f2 = $k . "-en.tag"; $al = $k . "-da-en.atag";
	system("perl $tools/check_sentence.pl $f1 $t2dir/$f2 $aldir/$al");
    }
}
