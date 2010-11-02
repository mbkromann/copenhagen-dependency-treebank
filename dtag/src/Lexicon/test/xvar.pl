package DTAG::LexInput;

DTAG::Lexicon->new("test")->clear();

# Atomic inheritance
#
#             i   h
#              \ /
#     G   F E   d
#      \ /   \ /
#      c,C    b
#         \ /
#          a,A

# Type hierarchy
my $a = type("a", "c", "b");
my $A = type("A", "C", "b");
my $b = type("b", "E", "d");
my $c = type("c", "G", "F");
my $C = type("C", "G", "F");
my $d = type("d", "i", "h");
my $E = type("E");
my $F = type("F");
my $G = type("G");
my $h = type("h");
my $i = type("i");

my $x = type("x");
my $y = type("y");
my $xy = type("xy", "y", "x");
my $yx = type("yx", "x", "y");
my $z = type("z", "yx", "xy");
my $Z = type("Z", "yx", "xy");

# Declare variables
my @vars = ("a", "A", "b", "c", "C", "d", "E", "F", "G", "h", "i",
	"x", "y", "xy", "yx", "z", "Z");

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

# ------------------------------
#   Test procedures
# ------------------------------

# Test atomic inheritance: testA($var, $value);
sub testA {
	my $var = DTAG::Lexicon::typeobj(shift);
	my $val = shift;
	my ($type, $value) = DTAG::Lexicon->xvar($var, "atom");
	print $var->get_name() . " = $val = $type:$value\n";
} 

# Test list inheritance: testL($var, [$value0, $value1, $value2, $value3]);
sub testX {
	my $var = DTAG::Lexicon::typeobj(shift);
	my $values = shift;
	my $name = shift;

	foreach my $inh (0,1,2,3) {
		# Set inheritance in all vars to $inh
		foreach my $v (@vars) {
			my $vobj = DTAG::Lexicon::typeobj($v);
			if ($vobj->lvar($name)) {
				$vobj->lvar($name)->inherit($inh);
			}
		}

		# Calculate value
		my $val = $values->[$inh];
		my ($type, $value) = DTAG::Lexicon->xvar($var, $name);
		if ($name ne "hash") {
			print $var->get_name() . ":$inh = $val = $type:[" 
				. join(",", @$value) . "]:" . ref($value) . "\n";
		} else {
			print $var->get_name() . ":$inh = $val = $type:{";
			my @args = ();
			if (ref($value) eq "HASH") {
				foreach my $key (sort(keys %$value)) {
					push @args, "$key=>" . $value->{$key};
				}
			}
			print join(",", @args) . "}:" . ref($value) . "\n";
		}
	}
	print "---\n";
}

sub testL {
	testX(@_, "list");
}

sub testS {
	testX(@_, "set");
}

sub testH {
	testX(@_, "hash");
}

# ------------------------------
#   Test atomic inheritance
# ------------------------------

print "\nTEST ATOMIC INHERITANCE\n";
testA("a", "9:E");
testA("A", "9:A");
testA("b", "9:E");
testA("c", "9:F");
testA("C", "9:C");
testA("d", "0:undef");
testA("E", "9:E");
testA("F", "9:F");
testA("G", "9:G");
testA("h", "0:undef");
testA("i", "0:undef");

# ------------------------------
#   Test list inheritance
# ------------------------------

# Test list inheritance: testL($var, [$value0, $value1, $value2, $value3]);
print "\nTEST LIST INHERITANCE\n";
testL("h", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testL("i", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testL("d", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testL("E", ["26:[E1,E2]", "26:[E1,E2]", "42:[E1,E2]", "42:[E1,E2]"]);
testL("b", ["26:[E1,E2]", "26:[E1,E2]", "42:[E1,E2]", "42:[E1,E2]"]);
testL("F", ["26:[F2]", "26:[F2]", "42:[F2]", "42:[F2]"]);
testL("G", ["26:[G1,G2]", "26:[G1,G2]", "42:[G1,G2]", "42:[G1,G2]"]);
testL("c", ["26:[F2]", "26:[F2]", "42:[F2,G1,G2]", "42:[F2,G1,G2]"]);
testL("C", ["26:[C1,C2]", "26:[F2,C1,C2]", "42:[C1,C2]", "42:[F2,G1,G2,C1,C2"]);
testL("a", ["26:[E1,E2]", "26:[E1,E2]", "42:[E1,E2,F2,G1,G2]",
	"42:[E1,E2,F2,G1,G2]"]);
testL("A", ["26:[A1,A2]", "26:[E1,E2,A1,A2]", "42:[A1,A2]",
	"42:[E1,E2,F2,G2,C1,C2,A1,A2]"]);


# ------------------------------
#   Test set inheritance
# ------------------------------

# Test set inheritance: testL($var, [$value0, $value1, $value2, $value3]);
print "\nTEST LIST INHERITANCE\n";
testS("h", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testS("i", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testS("d", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testS("E", ["27:[E,x,y]", "27:[E,x,y]", "43:[E,x,y]", "43:[E,x,y]"]);
testS("b", ["27:[E,x,y]", "27:[E,x,y]", "43:[E,x,y]", "43:[E,x,y]"]);
testS("F", ["27:[w]", "27:[w]", "43:[w]", "43:[w]"]);
testS("G", ["27:[G,x]", "27:[G,x]", "43:[G,x]", "43:[G,x]"]);
testS("c", ["27:[w]", "27:[w]", "43:[w,G,x]", "43:[w,G,x]"]);
testS("C", ["27:[C]", "27:[w,C]", "43:[C]", "43:[w,G,x,C]"]);
testS("a", ["27:[E,x,y]", "27:[E,x,y]", "43:[E,x,y,w,G]", "43:[E,x,y,w,G]"]);
testS("A", ["27:[A,z]", "27:[E,y,A,z]", "43:[A,z]", "43:[E,y,w,G,C,A,z]"]);


# ------------------------------
#   Test hash inheritance
# ------------------------------

print "\nTEST HASH INHERITANCE\n";
testH("h", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testH("i", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testH("d", ["0:undef", "0:undef", "0:undef", "0:undef"]);
testH("E", ["28:{E=>1,x=>5}", "28:{E=>1,x=>5}", "44:{E=>1,x=>5}",
	"44:{E=>1,x=>5}"]);
testH("b", ["28:{E=>1,x=>5}", "28:{E=>1,x=>5}", "44:{E=>1,x=>5}",
	"44:{E=>1,x=>5}"]);
testH("F", ["28:{F=>1,x=>6,w=>6}", "28:{F=>1,x=>6,w=>6}", 
	"44:{F=>1,x=>6,w=>6}", "44:{F=>1,x=>6,w=>6}"]);
testH("G", ["28:{G=>1,x=>7}", "28:{G=>1,x=>7}", "44:{G=>1,x=>7}",
	"44:{G=>1,x=>7}"]);
testH("c", ["28:{F=>1,w=>6,x=>6}", "28:{F=>1,w=>6,x=>6}", 
	"44:{F=>1,G=>1,w=>6,x=>6}", "44:{F=>1,G=>1,w=>6,x=>6}"]);
testH("C", ["28:{C=>1,x=>3,y=>3}", "28:{C=>1,F=>1,x=>3,y=>3}", 
	"44:{C=>1,x=>3,y=>3}", "44:{C=>1,F=>1,G=>1,x=>3,y=>3}"]);
testH("a", ["28:{E=>1,x=>5}", "28:{E=>1,x=>5}", 
	"44:{E=>1,F=>1,G=>1,w=>6,x=>5}", "44:{E=>1,F=>1,G=>1,w=>6,x=>5}"]);
testH("A", ["28:{A=>1}", "28:{A=>1,E=>1}", 
	"44:{A=>1}", "44:{A=>1,C=>1,E=>1,F=>1,G=>1,y=>3}"]);


# ------------------------------
#   Test multiple inheritance
# ------------------------------

testL("z", ["26:[x]", "26:[x]", "42:[x,y]", "42:[x,y]"]);
testL("Z", ["26:[Z]", "26:[x,Z]", "42:[Z]", "42:[x,y,Z]"]);


# ------------------------------
#   Test error messages
# ------------------------------

print "EXPECT ERRORS after this\n";

$|=1;

# Variables
my $s = type("s");
my $t = type("t", "s");
my $u = type("u");

$s->lvar("x", 7);
$t->lvar("x", list([1], [], 3));
$u->lvar("x", hash([1=>2], []));

DTAG::LexInput->lexicon()->compile();

# Tests
print $t->get_name() . ".x = [" . join(",", @{$t->var("x")}) . "]\n";
print $u->var("x");


