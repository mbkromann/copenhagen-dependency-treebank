package DTAG::LexInput;

DTAG::Lexicon->new("test")->clear();

#      c 
#     /     c:  L+=[ 3]  w=3  x=3  y=3  z=3
#    C b    C:  L+=[-3]
#    |/     b:  L+=[ 2]  w=2  x=2  y=2 
#    B a    B:  L+=[-2]
#    |/     a:  L+=[ 1]  w=1  x=1
#    A      A:  L+=[-1]  w=-1

my $Avars = {
	'L0' => '[-1]',
	'L1' => '[1,-1]',
	'L2' => '[-1]',
	'L3' => '[1,2,3,-3,-2,-1]',
	'w' => '-1',
	'x' => '1',
	'y' => '2',
	'z' => '3'};

use Data::Dumper;
$Data::Dumper::Indent=0;
sub dumpstr {
    my $obj = shift;
    my $str = Dumper($obj);
    $str =~ s/^.*=\s*(.*)\s*;\s*$/$1/g;
    return $str;
}


# Type hierarchy
my $A = type("A", "a");
my $B = type("B", "b");
my $C = type("C", "c");
my $a = type("a");
my $b = type("b");
my $c = type("c");

my $A1 = type("A1", "B1", "a");
my $B1 = type("B1", "C1", "b");
my $C1 = type("C1", "c");

$a->lvar("w", 1);
$b->lvar("w", 2);
$c->lvar("w", 3);
$A->lvar("w", -1);
$A1->lvar("w", -1);

$a->lvar("x", 1);
$b->lvar("x", 2);
$c->lvar("x", 3);

$b->lvar("y", 2);
$c->lvar("y", 3);

$c->lvar("z", 3);

$A->lvar("L0", list([-1], [], 0));
$B->lvar("L0", list([-2], [], 0));
$C->lvar("L0", list([-3], [], 0));
$A1->lvar("L0", list([-1], [], 0));
$B1->lvar("L0", list([-2], [], 0));
$C1->lvar("L0", list([-3], [], 0));
$a->lvar("L0", list([1], [], 0));
$b->lvar("L0", list([2], [], 0));
$c->lvar("L0", list([3], [], 0));

$A->lvar("L1", list([-1], [], 1));
$B->lvar("L1", list([-2], [], 1));
$C->lvar("L1", list([-3], [], 1));
$A1->lvar("L1", list([-1], [], 1));
$B1->lvar("L1", list([-2], [], 1));
$C1->lvar("L1", list([-3], [], 1));
$a->lvar("L1", list([1], [], 1));
$b->lvar("L1", list([2], [], 1));
$c->lvar("L1", list([3], [], 1));

$A->lvar("L2", list([-1], [], 2));
$B->lvar("L2", list([-2], [], 2));
$C->lvar("L2", list([-3], [], 2));
$A1->lvar("L2", list([-1], [], 2));
$B1->lvar("L2", list([-2], [], 2));
$C1->lvar("L2", list([-3], [], 2));
$a->lvar("L2", list([1], [], 2));
$b->lvar("L2", list([2], [], 2));
$c->lvar("L2", list([3], [], 2));

$A->lvar("L3", list([-1], [], 3));
$B->lvar("L3", list([-2], [], 3));
$C->lvar("L3", list([-3], [], 3));
$A1->lvar("L3", list([-1], [], 3));
$B1->lvar("L3", list([-2], [], 3));
$C1->lvar("L3", list([-3], [], 3));
$a->lvar("L3", list([1], [], 3));
$b->lvar("L3", list([2], [], 3));
$c->lvar("L3", list([3], [], 3));

DTAG::LexInput->lexicon()->compile();


# Print all variables for $A

foreach my $v ("x", "y", "z", "w", "L0", "L1", "L2", "L3") {
	my ($type, $val) = DTAG::Lexicon->xvar([$C, $B, $A], $v);
	print "A : $v = " . dumpstr($val) . " (" . $Avars->{$v} .  " = correct)\n";

	($type, $val) = DTAG::Lexicon->xvar($A1, $v);
	print "A1: $v = " . dumpstr($val) . " (" . $Avars->{$v} .  " = correct)\n";
}

# Change graph:
#      c
#     /|    c:  L+=[ 3]  w=3  x=3  y=3  z=3
#    C b    C:  L+=[-3]
#    |/|    b:  L+=[ 2]  w=2  x=2  y=2 
#    B a    B:  L+=[-2]
#    |/     a:  L+=[ 1]  w=1  x=1
#    A      A:  L+=[-1]  w=-1

my $Avars = {
	'L0' => '[-1]',
	'L1' => '[3,2,1,-1]',
	'L2' => '[-1]',
	'L3' => '[3,2,1,-3,-2,-1]',
	'w' => '-1',
	'x' => '1',
	'y' => '2',
	'z' => '3'};

print "****\n";

my $a = DTAG::Lexicon::typeobj("a");
my $b = DTAG::Lexicon::typeobj("b");
my $c = DTAG::Lexicon::typeobj("c");
my $A = DTAG::Lexicon::typeobj("A");
my $B = DTAG::Lexicon::typeobj("B");
my $C = DTAG::Lexicon::typeobj("C");
my $A1 = DTAG::Lexicon::typeobj("A1");

$a->set_super("c", "b");
$b->set_super("c");

foreach my $v ("x", "y", "z", "w", "L0", "L1", "L2", "L3") {
	my ($type, $val) = DTAG::Lexicon->xvar([$C, $B, $A], $v);
	print "A : $v = " . dumpstr($val) . " (" . $Avars->{$v} .  " = correct)\n";

	($type, $val) = DTAG::Lexicon->xvar($A1, $v);
	print "A1: $v = " . dumpstr($val) . " (" . $Avars->{$v} .  " = correct)\n";
}
