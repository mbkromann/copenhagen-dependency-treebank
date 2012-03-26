# the reason why Danish+English is prepared differently from
# other languages is that the most reliable version comes from
# Martin Haulrich's email, not from SVN

help:
        @echo type 'make daen other' to collect all annotated data in this dir

daen:
        tar -xzf daen.tar.gz

other:
        ln ../../../it it -s
        ln ../../../es es -s
        ln ../../../de de -s
        ln ../../../da-it da-it -s
        ln ../../../da-es da-es -s
        ln ../../../da-de da-de -s


select:
	./select_atag_files.pl > selection.log

types:
	cat selection.log | grep SELE | cut -f2 | ./test_new_file_names.pl | sort | uniq -c | sort -nr > typefreq