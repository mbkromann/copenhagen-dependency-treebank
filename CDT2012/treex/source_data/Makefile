# the reason why Danish+English is prepared differently from
# other languages is that the most reliable version comes from
# Martin Haulrich's email, not from SVN

help:
	@echo type 'make daen other' to collect all annotated data in this dir

daen:
	tar -xzf daen.tar.gz

other:
	ln ../../../it source_data/it -s
	ln ../../../es source_data/es -s
	ln ../../../de source_data/de -s
	ln ../../../da-it source_data/da-it -s
	ln ../../../da-es source_data/da-es -s
	ln ../../../da-de source_data/da-de -s