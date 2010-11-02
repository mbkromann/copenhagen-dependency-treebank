package DTAG::LexInput;


my $hash = {'a' => 'b', 'c' => 'd'};

printf "a=" . $hash->{'a'} 
	. " c=" . $hash->{'c'}
	. " d=" . $hash->{'d'} . "\n";

if ($hash->{'d'} == undef) {
	printf "d is undefined\n";
}

# Defining locally specified values
$hash->{'var'} = 'value';

# Defining multi-inherited values
#$hash->{'var'} = multi('plus-list', 'minus-list');

my $array = [1,2,3];
my $type = Type->new("a");

#printf "ref($array) = " . ref($array) . "\n";
#printf "ref($type) = " . ref($type) . "\n";
#printf substr("string", 0, 1) . substr("string", 1, 1) . "\n";
