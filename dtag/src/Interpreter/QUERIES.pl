# Query parser
my $query_parser;
$::RD_HINT = 1;

# Query language grammar
my $query_grammar = q{
	FindExpression : 
		Option(s?) Query Action(s?)
			{	my $hash = {};
				foreach my $h (@{$item[1]}) {
					map {$hash->{$_} = $h->{$_}} keys(%$h);
				}
				{ 'options' => $hash,
					'query' => $item[2], 
					'actions' => $item[3]} }

	Option : 
		  '-corpus' 	{{'corpus' => 1}}
		| '-debug'		{{'debug' => 1}}
		| '-dump'		{{'dump' => 1}}
		| '-parse'		{{'debug_parse' => 1}}
		| '-dnf'		{{'debug_dnf' => 1}}
		| '-yes'		{{'replace-all' => 1}}
		| '-maxtime=' /[0-9]+/
						{{'maxtime' => $item[2]}}
		| '-maxmatch=' /[0-9]+/
						{{'maxmatch' => $item[2]}}
		| '-onOpen(' <leftop: DTAGCommand ";" DTAGCommand> ')'
			{ 'opOpen' => FindActionDTAG->new(@{$item[2]}) }
		| '-onClose(' <leftop: DTAGCommand ";" DTAGCommand> ')'
			{ 'onClose' => FindActionDTAG->new(@{$item[2]}) }
		| '-vars(' <leftop: NodeVariableDeclaration "," NodeVariableDeclaration > ')'
			{	my $hash = {}; 
				map {$hash->{$_->[0]} = ($_->[1] || "")} @{$item[2]};
				{'vars' => $hash }; }

	Action :
		  '-do(' <leftop: DTAGCommand ";" DTAGCommand> ')'
			{ FindActionDTAG->new(@{$item[2]}) }
		| <error>

	Query :
		  UnaryQuery ( "∨" | "||" | "|" | "OR" | "or" ) <leftop: UnaryQuery ( "∨" | "||" | "|" | "OR" | "or" ) UnaryQuery>
			{ FindOR->new($item[1], DTAG::Interpreter::objects(@{$item[3]})) }
		| UnaryQuery /∧|\&\&|\&|AND|and/ <leftop: UnaryQuery /∧|\&\&|\&|AND|and/ UnaryQuery>
			{ FindAND->new($item[1], DTAG::Interpreter::objects(@{$item[3]})) }
		| UnaryQuery ( "→" | "⇒" | "IMPLIES" | "implies" | "->") UnaryQuery
			{ FindOR->new(FindNOT->new($item[1]), $item[3]) }
		| UnaryQuery ( "←" | "⇐" | "IF" | "if" | "<-") UnaryQuery
			{ FindOR->new(FindNOT->new($item[3]), $item[1]) }
		| UnaryQuery
			{ $item[1] }
		

	UnaryQuery :
		  '(' Query ')'
			{ $item[2] }
		| ( "¬" | "!" | "NOT" | "not" ) UnaryQuery
			{ FindNOT->new($item[2]) }
		| ExistQuantifier (NodeVariableDeclaration | Node) '(' Query ')'
			{ FindEXIST->new($item[2], $item[4]) }
		| ExistQuantifier '(' (NodeVariableDeclaration | Node) ',' Query ')'
			{ FindEXIST->new($item[3], $item[5]) }
		| AllQuantifier (NodeVariableDeclaration | Node) '(' Query ')'
			{	FindEXIST->new($item[2], FindNOT->new($item[4]))
				->setNegated() }
		| AllQuantifier '(' (NodeVariableDeclaration | Node) ',' Query ')'
			{	FindEXIST->new($item[3], FindNOT->new($item[5]))
				->setNegated() }
		| SimpleQuery

	ExistQuantifier :
		( "∃" | "EXISTS" | "EXIST" | "E" | "exists" | "exist" ) 

	AllQuantifier :
		( "∀" | "ALL" | "A" | "all" )

	SimpleQuery : 
		  StringValueQuery
		| AdjacencyQuery
		| NumberValueQuery
		| GraphQuery
		| AlignmentQuery

	StringValueQuery : 
		  StringValue 'eq' StringValue
			{ FindStringEQ->new($item[1], $item[3]) }
		| StringValue 'ne' StringValue
			{ FindStringEQ->new($item[1], $item[3])->setNegated() }
		| StringValue '=~' RegularExpression
			{ FindStringRegExp->new($item[3], $item[1]) }
		| StringValue '!~' RegularExpression
			{ FindStringRegExp->new($item[3], $item[1])->setNegated() }

	NumberValueQuery :
		  NumberValue ( "==" | "=" ) NumberValue
			{ FindNumberEQ->new($item[1], $item[3]) }
		| NumberValue ( "!=" | "≠" ) NumberValue 
			{ FindNumberEQ->new($item[1], $item[3])->setNegated() }
		| NumberValue ( "<=" | "≤" ) NumberValue
			{ FindNumberGT->new($item[1], $item[3])->setNegated() }
		| NumberValue ( ">=" | "≥" ) NumberValue
			{ FindNumberLT->new($item[1], $item[3])->setNegated() }
		| NumberValue "<" NumberValue
			{ FindNumberLT->new($item[1], $item[3]) }
		| NumberValue ">" NumberValue
			{ FindNumberGT->new($item[1], $item[3]) }

	AdjacencyQuery : 
		  Node '>>' Node
			{ FindADJ->new($item[1], $item[3], [[1,1]], -1) }
		| Node '<<' Node
			{ FindADJ->new($item[1], $item[3], [[1,1]], 1) }
		| Node '>' Range '>' Node
			{ FindADJ->new($item[1], $item[5], $item[3], -1) }
		| Node '<' Range '<' Node
			{ FindADJ->new($item[1], $item[5], $item[3], 1) }

	GraphQuery : 
		  Node RelationPattern Node
		  	{ FindEdge->new($item[1], $item[3], $item[2]) }
		| Node "path(" PathPattern ")" Node
			{ FindPath->new($item[1], $item[5], $item[3]) }
	
	AlignmentQuery : 
		"@(" NodeList ";" NodeList ")"
			{ FindAlign->new($item[2], $item[4], undef) }
		| "@" RelationPattern "(" NodeList ";" NodeList ")"
			{ FindAlign->new($item[4], $item[6], $item[2]) }
	
	RelationPattern :
		"isa(" Type "," Identifier ")"
			{ FindMatchStringIsa->new($item[2], $item[4]) }
		| "isa(" Type ")"
			{ FindMatchStringIsa->new($item[2]) }
		| /\/[^\/]+\//
			{ FindMatchStringRegExp->new($item[1]) }
		| RelationName
			{ FindMatchStringEQ->new($item[1]) }

	RelationName : 
		  '"' StringWithNoDoubleQuotes '"'
			{ $item[2] }
		| Identifier

	NodeList : 
		"!" <leftop: Node "," Node>
			{ ("!", $item[2]) }
		| <leftop: Node "," Node>
			{ $item[1] }
	
	Type : 
		  UnaryType "+" <leftop: UnaryType "+" UnaryType >
		    { FindTypePlus->new($item[1], @{$item[3]}) }
		| UnaryType "-" <leftop: UnaryType "-" UnaryType >
		    { FindTypeMinus->new($item[1], @{$item[3]}) }
		| UnaryType "|" <leftop: UnaryType "|" UnaryType >
		    { FindTypeOr->new($item[1], @{$item[3]}) }
		| "-" UnaryType
		    { FindTypeNot->new($item[2]) }
		| UnaryType

	UnaryType :
		  "(" Type ")"
			{ $item[2] } 
		| "!" TypeName
			{ FindTypeAtomic->new($item[2], 1) }
		| TypeName
			{ FindTypeAtomic->new($item[1]) }

	TypeName : 
		  '"' StringWithNoDoubleQuotes '"' 
		  	{ $item[2] }
		| Identifier
		  	{ $item[1] }

	PathPattern : 
		UnaryPathPattern(s)
		
	UnaryPathPattern : 
		  '(' PathPattern ')'
		  	{ $item[2] }
		| '>' RelationPattern
		  	{ ['>', $item[2]] }
		| '<' RelationPattern
			{ ['<', $item[2]] }
		| '{' PathPattern '}ُ+'
			{ ['+', $item[2], 1, undef] }
		| '{' PathPattern '}*' 
			{ ['+', $item[2], 0, undef] }
		| '{' PathPattern '}(' Integer '..' Integer ')'
			{ ['+', $item[2], $item[4], $item[6]] }
		| '{' PathPattern '}(' '..' Integer ')'
			{ ['+', $item[2], 0, $item[5]] }
		| '{' PathPattern '}(' Integer '..' ')'
			{ ['+', $item[2], $item[4], undef] }
		| '{' PathPattern '}(' Integer ')'
			{ ['+', $item[2], $item[4], $item[4]] }

	GraphKey : /[a-zA-Z]+/

	Value : 
		<skip: '[ \t]*'> StringValue
		| <skip: '[ \t]*'> NumberValue

	StringValue :
		  'etypes(' Node ',' Node ')'
		  	{ FindStringValueEtype->new($item[2], $item[4]) }
		| 'etypes(' Node RelationPattern Node ')'
		  	{ FindStringValueEtype->new($item[2], $item[4], $item[3]) }
		| IntegerValue '[' Feature ']'
		  	{ FindStringValueNodeFeature->new($item[1], $item[3]) }
		| Node "[]"
			{ FindStringValueNodeFeature->new(
				FindNumberValueNode->new($item[1]), undef) }
		| '"' /[^"]*/ '"'
			{ FindStringValue->new($item[2]) }

	IntegerValue : 
		Node
			{ FindNumberValueNode->new($item[1]) }
		| Integer
			{ FindNumberValue->new($item[1]) }

	NumberValue :
		  IntegerValue '[' Feature ']'
		  	{ FindNumberValueNodeFeature->new($item[1], $item[3]) }
		| Float
			{ FindNumberValue->new($item[1]) }
		| IntegerValue
			{ $item[1] }
		| "is(" Query ")"
			{ FindNumberValueQuery->new($item[2]) }
	
	Range :
		<leftop: SimpleRange "," SimpleRange>

	SimpleRange : 
		Integer ".." Integer
			{ [$item[1], $item[3]] }
		| Integer
			{ [$item[1], $item[1]] }

	DTAGCommand :
		<skip: ''> DTAGCommandSegment(s)
		| <error>

	DTAGCommandSegment :
		'`' Value '`'
			{$item[2]}
		| Node
			{ FindNumberValueNode->new($item[1]) }
	 	| DTAGCommandString
			{ FindStringValue->new($item[1]) }
		| '(' DTAGCommandString ')'
			{ FindStringValue->new('(' . $item[2] . ')') }

	DTAGCommandString :
		/[^\\\\$()`]+/
		| '\t' { '	' }
		| '\n' { '\n' }
		| '\r' { '\r' }
		| '\(' { "(" }
		| '\)' { ")" }
		| '\\\' '\\\' { "\\\" }

	NodeVariableDeclaration :
		Node "@" GraphKey
			{ [$item[1], $item[3]] }

	RegularExpression : 
		/\/[^\/]*\//
			{ $item[1] }

	Node : /\$[a-zA-Z][a-zA-Z0-9_]*/
		| /[0-9]+/

	Feature : 
		'"' /[^"]+/ '"'
			{ $item[2] }
		| /[^]]+/
			{ $item[1]}

	FileName : '"' StringWithNoBlanksNoQuotes '"'
		{ $item[2] }

	Identifier :
		/[^()\s,;+=<>≤≥|-]+/

	StringWithNoDoubleQuotes : 
		/[^"]+/

	StringWithEscapedSlash : 
		/([^\/]*\/)*[^\/]*/

	StringWithEscapedParentheses : 
		/([^()]+(\\(|\\)))*[^()]*/

	StringWithEscapedParenthesesNoBlanks :
		/[^()\s]+((\\(|\\))[^()\s]*)*/

	StringWithEscapedParenthesesNoBlanksNoQuotes :
		/[^()"\s]+((\\(|\\))[^()"\s]*)*/

	StringWithNoBlanksNoQuotes :
		/[^"\s]+/

	Integer : 
		/[-+]?[0-9]+/

	Float : 
		/[-+]?[0-9]+(\.[0-9]+)?/

};

sub objects {
	my $list = [];
	while (@_) {
		my $arg = shift;
		push @$list, $arg
			if (ref($arg));
	}
	return @$list;
}

# Parser object
#my $query_parser = undef;
#$Parse::RecDescent::skip = '';


# Find all subjects that have been aligned to non-subjects.
# find exists($ys, $xs subj $ys) 
# 	& ! exists($xt, exists($yt, ($xt subj $yt)) & @($xs, $xt))
#TE=∃   FA=∀
# find E($ys, $xs subj $ys) 
# 	& ! E($xt, ∃($yt, ($xt subj $yt)) & @($xs,$xt))
# find ∃($ys, $xs@a & $xs subj $ys) 
# 	& ! ∃($xt, $xt@b & ∃($yt, ($xt subj $yt)) & @($xs, $xt))


# @($x,...;$y,...)					# alignment without label constraint
# @($x,...;$y,...) == $label		# alignment with label
# @($x,...;$y,...) =~ /$label/		# alignment with matching label
# @$A($x,...;$y,...) ...            # as before, but with alignment node $A
#

# Functions
# in($A): in-degree
# out($A): out-degree
# $x[$var]: node feature value
# $x : node position


# find $x@a & $y@b & $A@(a,b) & $A@($x,$y,$z,...):label & 
