package DTAG::LexInput; 

my $list = list(["a", "b", "c"], ["a"], 1);
my $list2 = list(["a", "b", "c"], ["a"]);
my $list3 = list(["a", "b", "c"]);
my $set = set(["d", "e", "f"], ["f"], 2);
my $hash = hash({"g"=>1, "h"=>2, "i"=>3}, ["g"], 3);

print $list->print() . "\n";
print $set->print() . "\n";
print $hash->print() . "\n";
print $list2->print() . "\n";
print $list3->print() . "\n";


