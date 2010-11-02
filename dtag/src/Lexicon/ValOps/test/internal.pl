
my $val = ValOp->new(["a"], ["b"], 5);
my $hash = HashVal->new({"a"=>"b", "c"=>"d"}, ["c"], 1);
my $list = ListVal->new(["a", "b"], ["a"], 2);
my $set = SetVal->new(["a", "b"], ["a"], 2);

print $val->print() . "\n";
print $hash->print() . "\n";
print $list->print() . "\n";
print $set->print() . "\n";


