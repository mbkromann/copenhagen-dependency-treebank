sub nice_string {
       join("",
         map { $_ > 255 ?                  # if wide character...
               sprintf("\\x{%04X}", $_) :  # \x{...}
               chr($_) =~ /[[:cntrl:]]/ ?  # else if control character...
               sprintf("\\x%02X", $_) :    # \x..
               chr($_)                     # else as themselves
         } unpack("U*", $_[0]));           # unpack Unicode characters
   }
