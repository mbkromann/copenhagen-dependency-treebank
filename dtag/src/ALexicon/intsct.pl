# Intersect two ordered lists
sub intsct {
	my $list1 = shift || [];
	my $list2 = shift || [];

	$list1 = [ sort {$a <=> $b} @$list1 ];
	$list2 = [ sort {$a <=> $b} @$list2 ];

	# Initialize variables
	my $intsct = [];
	my $i = 0;
	my $j = 0;
	$| = 1;
	
	# Intersect lists
	while ($i < scalar(@$list1) && $j < scalar(@$list2)) {
		if ($list1->[$i] == $list2->[$j]) {
			push @$intsct, $list1->[$i];
			++$i;
			++$j;
		} elsif ($list1->[$i] < $list2->[$j]) {
			$i = find_first_ge($list1, $list2->[$j], $i);
		} elsif ($list1->[$i] > $list2->[$j]) {
			$j = find_first_ge($list2, $list1->[$i], $j);
		}
	}

	# Return intersection
	return $intsct;
}

sub find_first_ge {
	my $list = shift;
	my $value = shift;
	my $i1 = shift;
	my $i2 = scalar(@$list) - 1; 

	# Search for first index where $list[$i] >= $value
	while ($list->[$i1] < $value && $i1 != $i2) {
		my $mid = int(($i1 + $i2 + 1) / 2);
		if ($list->[$mid] < $value) {
			$i1 = $mid;
		} elsif ($mid == $i1 + 1 && $list->[$i1] < $value) {
			$i1 = $i2 = $mid;
		} else {
			$i2 = $mid;
		}
	}

	# Return index
	return $list->[$i1] < $value ? $i1 + 1 : $i1;
}
