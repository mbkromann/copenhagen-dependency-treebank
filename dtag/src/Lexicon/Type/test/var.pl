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

# Atomic variables
$A->var("atom", "A");
$C->var("atom", "C");
$E->var("atom", "E");
$F->var("atom", "F");
$G->var("atom", "G");

DTAG::LexInput->lexicon()->compile();

my @vars = ($a, $A, $b, $c, $C, $d, $E, $F, $G, $h, $i);

# ------------------------------
#   Test procedures
# ------------------------------

# Test atomic inheritance: testA($var, $value);
sub testA {
	my $type = shift;
	my $val = shift;
	my $value = $type->var("atom");
	print $type->get_name() . " = $val = $value\n";
} 


# ------------------------------
#   Test atomic inheritance
# ------------------------------

print "\nTEST ATOMIC INHERITANCE\n";
testA($a, "9:G");
testA($A, "9:A");
testA($b, "9:E");
testA($c, "9:G");
testA($C, "9:C");
testA($d, "0:undef");
testA($E, "9:E");
testA($F, "9:F");
testA($G, "9:G");
testA($h, "0:undef");
testA($i, "0:undef");


