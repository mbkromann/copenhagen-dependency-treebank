
my $e = Edge->new();

print $e->print() . "\n";

# Set variables
$e->in(1);
$e->out(2);
$e->type(3);

print $e->print() . "\n";
