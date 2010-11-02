package DTAG::LexInput;
require DTAG::Interpreter;

DTAG::Lexicon->new("test")->clear();

# Test copying of hashes and arrays
my $hash = { 'a' => 1, 'b' => [1,2,[3,4]], 'c' => {'c1' => 1, 'c2' =>
	[1,2], 'c3' => {'c31' => 1, 'c32' => 2}}};

my $lex = DTAG::LexInput->lexicon();
my $copy = $lex->copy_obj($hash);

print "hash = " . DTAG::Interpreter->dump($hash) . "\n";
print "copy = " . DTAG::Interpreter->dump($copy) . "\n\n";

# Test copying of source-objects
my $src = {'a' => ['<a|0>', {'3' => '<a|1|3>', '2' => '<a|1|2>'}, '<a|2>'], 
	'b' => {'1' => ['<b|1|0>', '<b|1|1>', '<b|1|2>'], '2' => '<b|2>'}};

my $hash = { 'a' => source('a|1|3'), 'b' => '<b>', 'c' =>
	[source('b|1'), 1, source('b|2')] };
my $copy = $lex->copy_obj($hash, $src);

print "src = " . DTAG::Interpreter->dump($src) . "\n";
print "hash = " . DTAG::Interpreter->dump($hash) . "\n";
print "copy = " . DTAG::Interpreter->dump($copy) . "\n\n";



