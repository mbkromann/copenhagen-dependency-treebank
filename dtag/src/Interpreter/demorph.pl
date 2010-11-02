# sub demorph {
# 	my $morph = shift;
# 	my $string = "";
# 	while ($morph) {
# 		# Perform operation
# 		if ($morph =~ s/^\[//) {
# 			# Find first matching "]"
# 			my $level = 1;
# 			my $pos = 0;
# 			while ($level > 0 && $pos < length($morph)) {
# 				my $c = substring($morph, $pos++, 1);
# 				if ($c eq "[") {
# 					++$level;
# 				} else if ($c eq "]") {
# 					--$level;
# 				}
# 			}
# 
# 			$string .= demorph(substr($morph, 0, $pos));
# 
# 		# Remove relation name
# 		$m =~ s/^([^/]*)\/.*$/\1/g;
# 
# 		# Perform action
# 		if ($m =~ /^(!+)([^!]*)$/) {
# 			# Deletion "!" with suffix
# 			my $del = length($1);
# 			my $suff = $2;
# 			$string = substr($string, 0, length($1));
# 		}
# 	}
# }
# 
# sub demorph_split {
# 	my $morph = shift;
# 
# 	# Find first part of morpheme (after calling demorph to substitute brackets
# 	# with substrings
# 	my $level = 0;
# 	for (my $i = 0; $i < length($morph); ++$i) {
# 		
# 	}
# 
# 
# 
# 
# # Commands:
# 
# 	demorph($string, $morph):
# 		return ($string2, $morph2);
# 
# 	Rewrite rules:
# 
# 		# X "/" Y => X
# 		if ($morph =~ /^(.*)\/[^\/]*$/) {
# 			# Strip trailing "/" part
# 			return ($string, $1);
# 		} else if ($morph =~ /^(!+)(.*)$/) {
# 			# Apply deletions
# 			$string = substr($string, 0, length($string) - length($1));
# 			return ($string, length($2) > 0 ? "+" . $2 : ""); 
# 		} else if ($morph =~ /^-
# 		# 
# 		# "!+" X => "!+" +X
# 		s/^(!+)(.+)$/
# 		X/Y			=> X
# 		!*[Y]		=> !* +X +[Y]
# 		+X[Y]W		=>
# 		
# 	!*X[Y]/Z		=> !*
# 	!*X/Z			=> 
# 	+X[Y]/W  		=> +X +[Y] +Z
# 	+X/W			=> +X
# 	-X[Y]Z/W		=> -Z -[Y] -X
# 	-X/W			=> -X
# 
# 
# 	"!!!!SUFFIX"
# 	"+SUFFIX"
# 	"-PREFIX"
# 	"-P
# 
