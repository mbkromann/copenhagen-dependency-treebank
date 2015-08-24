# CDT natural language tools #


## Sentence detector and tokenizer ##

We have created our own sentence detector and tokenizer [http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/tools/txt2tok](txt2tok.md) (under the same open-source license as the other tools). The tokenizer works quite well for all languages used in the project. You should preferably supply a list of abbreviations for the language. The abbreviation lists that we use are contained in the directory "dict".

## Part-of-speech taggers ##

For English, German, Italian, and Spanish, we have used Helmut Schmid's TreeTagger with its builtin settings for these languages. For Danish, we have trained the Stanford Postagger on the msd-tags in the Danish PAROLE corpus, ie, the files in `da/*.tag` and `da/tagged/*.tag`. The training file and tagger model are contained in the directory "dict".

## Parsers ##