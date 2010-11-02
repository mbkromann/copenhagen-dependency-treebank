my $a   = Type->new("a");
my $a_a = Type->new("a_a", $a);
my $b   = Type->new("b");
my $c   = Type->new("c");
my $abc = Type->new("abc", $a, $b, $c);
my $d   = Type->new("d", $abc, $a_a);

# Atomic tests
printf " 1. " . $a->is($a) . " = 1\n";
printf " 2. " . $a->is($b) . " = 0\n";
printf " 3. " . $a_a->is($a_a) . " = 1\n";
printf " 4. " . $a_a->is($a) . " = 1\n";
printf " 5. " . $a_a->is($b) . " = 0\n";
printf " 6. " . $abc->is($a) . " = 1\n";
printf " 7. " . $abc->is($b) . " = 1\n";
printf " 8. " . $abc->is($c) . " = 1\n";
printf " 9. " . $abc->is($d) . " = 0\n";
printf "10. " . $d->is($abc) . " = 1\n";
printf "11. " . $d->is($a) . " = 1\n";
printf "12. " . $d->is($b) . " = 1\n";
printf "13. " . $d->is($c) . " = 1\n";
printf "14. " . $d->is($a_a) . " = 1\n";
printf "15. " . $d->is($d) . " = 1\n";
printf "\n";

# Binary tests
printf "16. " . $abc->is("1", "1", "+") . " = 1\n";
printf "17. " . $abc->is("1", "0", "+") . " = 0\n";
printf "18. " . $abc->is("0", "1", "+") . " = 0\n";
printf "19. " . $abc->is("0", "0", "+") . " = 0\n";
printf "20. " . $abc->is($a, $b, "+") . " = 1\n";
printf "21. " . $abc->is($a, $d, "+") . " = 0\n";
printf "22. " . $abc->is($d, $a, "+") . " = 0\n";
printf "23. " . $abc->is($d, $a_a, "+") . " = 0\n\n";

printf "24. " . $abc->is("1", "1", "-") . " = 0\n";
printf "25. " . $abc->is("1", "0", "-") . " = 1\n";
printf "26. " . $abc->is("0", "1", "-") . " = 0\n";
printf "27. " . $abc->is("0", "0", "-") . " = 0\n";
printf "28. " . $abc->is($d, $b, "-") . " = 0\n";
printf "29. " . $abc->is($a, $d, "-") . " = 1\n";
printf "30. " . $abc->is($d, $a, "-") . " = 0\n";
printf "31. " . $abc->is($d, $a_a, "-") . " = 0\n\n";

printf "32. " . $abc->is("1", "1", "|") . " = 1\n";
printf "33. " . $abc->is("1", "0", "|") . " = 1\n";
printf "34. " . $abc->is("0", "1", "|") . " = 1\n";
printf "35. " . $abc->is("0", "0", "|") . " = 0\n";
printf "36. " . $abc->is($d, $b, "|") . " = 1\n";
printf "37. " . $abc->is($a, $d, "|") . " = 1\n";
printf "38. " . $abc->is($d, $a, "|") . " = 1\n";
printf "39. " . $abc->is($d, $a_a, "|") . " = 0\n\n";

# Trinary tests
my $cnt = 40;
foreach my $op1 ("+", "-", "|") {
	foreach my $op2 ("+", "-", "|") {
		foreach my $i (0,1) {
			foreach my $j (0,1) {
				foreach my $k (0,1) {
					printf $cnt++ . ". " 
						. $abc->is("$i", "$j", "$op1", "$k", "$op2") . " = "
						. "($i $op1 $j) $op2 $k\n";
				}
			}
		}
	}
}

foreach my $op1 ("+", "-", "|") {
	foreach my $op2 ("+", "-", "|") {
		foreach my $i (0,1) {
			foreach my $j (0,1) {
				foreach my $k (0,1) {
					printf $cnt++ . ". " 
						. $abc->is("$i", "$j", "$k", "$op2", "$op1") . " = "
						. "$i $op1 ($j $op2 $k)\n";
				}
			}
		}
	}
}
