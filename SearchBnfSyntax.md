## Search Bnf Syntax ##

### BNF syntax of search language ###

  * ''search'' ::= ''node'' `*:*` ''tspec'' | ''node'' `*&lt;*` ''node'' | ''node'' `*&gt;*` ''node'' | ''node'' `*==*` ''node'' | ''node'' `*!=*` ''node'' | ''node'' `*!=*` ''node'' | ''node'' ''espec'' ''node'' | ''node'' `*path(*`''pspec''`*)*` ''node'' | `*sort(*` ''level'' `*,*` ''sexpr'' **`)`** | `*(*` ''search'' `*)*` | `*!*` ''search'' | ''search'' **`,`** ''search'' | ''search'' **`&amp;`** ''search'' | ''search'' **`|`** ''search''
  * ''node'' ::= **`$`**''token''
  * ''tspec'' ::= ''token'' | `*(*` ''tspec'' `*)*` | ''tspec'' `*+*` ''tspec'' | ''tspec'' `*|*` ''tspec'' | ''tspec'' `*-*` ''tspec'' | `*-*` ''tspec''
  * ''espec'' ::= ''tspec''
  * ''pspec'' ::= `*&lt;*` ''espec'' | `*&gt;*` ''espec'' | `*{*` ''espec'' `*}+*` | ''pspec'' ''pspec''
  * ''level'' ::= ''integer''
  * ''sexpr'' ::= ''node'' `*-&gt;*` ''var''
  * ''var'' ::= ''token''


#### See also ####

