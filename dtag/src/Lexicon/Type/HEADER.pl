# This package defines a simple type in the lexicon, with the
# following variables:
#
#	name: the name of the type
#	super: a list of immediate super types
# 	variables: a hash of variable-value pairs
#
# and the following procedures:
#
#	$type->new := new type
#	$type->is(typedef) := 0/1: 
#	$type->super(type) := 0/1;
#	$type->join(types) := type;
#	$type->variables := variable hash;
#	$type->value(variable) := value;
#
# and the following creators used in lexica:
#
# 	type($name, $super1, ..., $superN)
#	lex($name, $super1, ..., $superN)
# 	map($name, $super1, ..., $superN)
#
# and the following modifiers:
#
# 	$type->super($tname1, ..., $tnameN)
# 	$type->phon($string)
#	$type->comp($edge1 => $tdef1, ..., $edgeN => $tdefN)
#	$type->land($tdef1, ..., $tdefN)
#	$type->cost($cfunc1, ..., $cfuncN)
#	$type->map($type1/listref1, ..., $typeN/listrefN)
#

package Type;
use strict;

my $undef = Type->new("__undef__");

