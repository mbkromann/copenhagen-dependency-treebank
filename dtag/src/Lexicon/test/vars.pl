package DTAG::LexInput;

DTAG::Lexicon->new("test")->clear();

# Atomic inheritance
#
#   h   i
#    \ /
#     d   E F   G
#      \ /   \ /
#       b     c,C
#         \ /
#          a,A
# 

# Type hierarchy
my $a = type("a", "b", "c");
my $A = type("A", "b", "C");
my $b = type("b", "d", "E");
my $c = type("c", "F", "G");
my $C = type("C", "F", "G");
my $d = type("d", "h", "i");
my $E = type("E");
my $F = type("F");
my $G = type("G");
my $h = type("h");
my $i = type("i");

my $x = type("x");
my $y = type("y");
my $xy = type("xy", "x", "y");
my $yx = type("yx", "y", "x");
my $z = type("z", "xy", "yx");
my $Z = type("Z", "xy", "yx");

my @vars = ($a, $A, $b, $c, $C, $d, $E, $F, $G, $h, $i, $x, $y, $xy,
	$yx, $z, $Z);

# Atomic variables
$A->lvar("atom", "A");
$C->lvar("atom", "C");
$E->lvar("atom", "E");
$F->lvar("atom", "F");
$G->lvar("atom", "G");


# List variables
$A->lvar("list", list(["A1", "A2"], ["G1"]));
$C->lvar("list", list(["C1", "C2"], []));
$E->lvar("list", list(["E1", "E2"], ["H1"]));
$F->lvar("list", list(["F1", "F2"], ["F1"]));
$G->lvar("list", list(["G1", "G2"], []));

# Set variables
$A->lvar("set", set(["A", "z"], ["x"]));
$C->lvar("set", set(["C"], ["z"]));
$E->lvar("set", set(["E", "x", "y"], ["H"]));
$F->lvar("set", set(["F", "w"], ["F"]));
$G->lvar("set", set(["G", "x"], []));

# Hash variables
$A->lvar("hash", hash({"A"=>1, "x"=>1}, ["x"]));
$C->lvar("hash", hash({"C"=>1, "x"=>3, "y"=>3}, ["w"]));
$E->lvar("hash", hash({"E"=>1, "x"=>5, "y"=>1}, ["y"]));
$F->lvar("hash", hash({"F"=>1, "x"=>6, "w"=>6}, []));
$G->lvar("hash", hash({"G"=>1, "x"=>7}, []));

# Multiple inheritance

$x->lvar("list", list(["x"], []));
$y->lvar("list", list(["y"], []));
$Z->lvar("list", list(["Z"], []));

# Compile lexicon
DTAG::LexInput->lexicon()->compile();

# Print variables
foreach my $v (@vars) {
	print $v->get_name() . ": " . join(" ", sort(@{DTAG::Lexicon->vars($v)})) . "\n";
}


