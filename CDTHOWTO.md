# HOWTO manual for performing different CDT tasks #



## Adding new texts for annotation ##

Here is a list of steps needed to add a new text corpus to the CDT repository. The texts should be in .odt format. When Martin comes back, he will also be able to help with the parsing and part-of-speech tagging.

  * **Source files**
    * Save the .odt file in the directory "cdt/src" with a name of the form "LANG-CORPUS.odt" (eg, "da-mycorpus.odt").
    * Save the .odt file in UTF8 format as "cdt/src/LANG-CORPUS.utf8" (use OpenOffice, "Save as", select "Text Encoded" format and then "UTF8").
    * Clean up the text file manually. We have encountered badly-formatted text files, so as a precaution, run the script "txt2txt" to clean up the text. You can do this from DTAG with the commands `cdt LANG` followed by `!cat LANG-CORPUS.utf8 | ~/cdt/tools/txt2txt > LANG-CORPUS.utf8.clean`.
    * Add the source files to the svn repository (from DTAG: `!svn add ~/cdt/src/da-mycorpus.*`).
  * **Text and TAG files**
    * The cleaned-up UTF8 file must be segmented into individual files and saved in the "cdt/LANG" directory. Use names of the form "CORPUS-XXXX-LANG.txt", save any citation references in "CORPUS-XXXX-LANG.cite". You can use your favorite text editor for this task.
    * Produce tag-files with the "da2tag" script (from DTAG: `da2tag CORPUS-XXXX-LANG.txt`), or the corresponding scripts "en2tag", "es2tag", "it2tag", "de2tag". (You will have to install various 3rd party software first via the cdt-lib.tgz archive: move the cdt-lib.tgz file to your home directory, then unpack it with "cd ; tar xvzf cdt-lib.tgz").
    * Add the files to the svn repository (from DTAG: `!svn add CORPUS-XXXX-LANG*`)
