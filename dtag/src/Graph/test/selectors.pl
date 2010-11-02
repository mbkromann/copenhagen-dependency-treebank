
my $g = DTAG::Graph->new();

print $g->print() . "\n";

$g->nodes([1,2,3]);
$g->input("input");
$g->position(4);
$g->boundaries([5,6,7]);
$g->vars({'a'=>'a','b'=>'b','c'=>'c'});

print $g->print() . "\n";
