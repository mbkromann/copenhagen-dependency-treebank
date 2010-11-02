my $a = new Type("a");
my $a_a = new Type ("a_a", $a);
my $b = new Type ("b");
my $c = new Type ("c");
my $abc = new Type ("abc", $a, $b, $c);
my $d = new Type ("d", $abc, $a_a);

printf " 1. " . $a->super($a) . " = 1\n";
printf " 2. " . $a->super($b) . " = 0\n";
printf " 3. " . $a_a->super($a_a) . " = 1\n";
printf " 4. " . $a_a->super($a) . " = 1\n";
printf " 5. " . $a_a->super($b) . " = 0\n";
printf " 6. " . $abc->super($a) . " = 1\n";
printf " 7. " . $abc->super($b) . " = 1\n";
printf " 8. " . $abc->super($c) . " = 1\n";
printf " 9. " . $abc->super($d) . " = 0\n";
printf "10. " . $d->super($abc) . " = 1\n";
printf "11. " . $d->super($a) . " = 1\n";
printf "12. " . $d->super($b) . " = 1\n";
printf "13. " . $d->super($c) . " = 1\n";
printf "14. " . $d->super($a_a) . " = 1\n";
printf "15. " . $d->super($d) . " = 1\n";

