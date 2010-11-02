
my $n = Node->new();

print $n->print() . "\n";

# Set variables
$n->input("input");
$n->segment("segment");
$n->position("position");
$n->lexemes(['lex1', 'lex2']);
$n->active(['act1', 'act2']);
$n->selected('selected');
$n->cost('cost1');
$n->in(['in1', 'in2']);
$n->out(['out1', 'out2']);
$n->extracted(['e1','e2']);
$n->layout('layout');

print $n->print() . "\n";

