ALL_SOURCE_DIR=all_source_data
SELECTED_SOURCE_DIR=selected_source_data
SELECTION=selection.log
RAW_TREEX_DIR=raw_treex
FINE_TREEX_DIR=fine_treex

help:
#	@echo type 'make daen other' to collect all annotated data in this dir


all: prepare select rawtreex finetreex

clean_all: clean_prepare clean_select clean_rawtreex clean_finetreex


#---------- STEP 1: preparation of source data --------------
# the reason why Danish+English data is prepared differently from
# other languages is that the most reliable version comes from
# Martin Haulrich's email, not from SVN
prepare:
	mkdir -p $(ALL_SOURCE_DIR)
	tar -xzf daen.tar.gz -C  $(ALL_SOURCE_DIR)
	ln ../../../../it  $(ALL_SOURCE_DIR)/it -s
	ln ../../../../es  $(ALL_SOURCE_DIR)/es -s
	ln ../../../../de  $(ALL_SOURCE_DIR)/de -s
	ln ../../../../da-it  $(ALL_SOURCE_DIR)/da-it -s
	ln ../../../../da-es  $(ALL_SOURCE_DIR)/da-es -s
	ln ../../../../da-de  $(ALL_SOURCE_DIR)/da-de -s
	./fix_wrong_encoding.pl

clean_prepare:
	rm -rf ./$(ALL_SOURCE_DIR)

#---------- STEP 2: selection of files for conversion --------------

select:
	./select_files_for_conversion.pl $(ALL_SOURCE_DIR) > $(SELECTION)
	mkdir -p $(SELECTED_SOURCE_DIR)
	cat $(SELECTION) | grep SELECT | cut -f2 -s | ./create_symlinks_to_selected_files.pl $(SELECTED_SOURCE_DIR) > symlinks.log

clean_select:
	rm -f $(SELECTION)
	rm -rf ./$(SELECTED_SOURCE_DIR)

# --------- STEP 3: raw conversion to treex -------------------


rawtreex:
	mkdir -p $(RAW_TREEX_DIR)
	ls $(SELECTED_SOURCE_DIR)/*tag | \
	treex Read::CdtPack from=- Util::Eval document="\$$doc->set_path(qw($(RAW_TREEX_DIR)))" \
	Write::Treex clobber=1 storable=1

clean_rawtreex:
	rm -rf ./$(RAW_TREEX_DIR)
	rm -rf dump*


# --------- STEP 4: changing to proper treex representation -------------------

finetreex:
	mkdir -p $(FINE_TREEX_DIR)
	treex \
	Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
	Misc::CopenhagenDT::ReconstructAlignmentLinks \
	Misc::CopenhagenDT::ImportSentSegmFromExternalFiles cdt_root_dir=../../../ \
	Misc::CopenhagenDT::SentSegmByTagS \
	Misc::CopenhagenDT::MoveDanishTreesToSeparateBundles \
	Misc::CopenhagenDT::MoveTreesToDanishCounterpartByAlignment \
	Misc::CopenhagenDT::MoveTreesToDanishCounterpartBySizeSimilarity \
	Misc::CopenhagenDT::DeleteFirstBundle \
	Util::Eval document="\$$doc->set_path(qw($(FINE_TREEX_DIR)))" \
	Write::Treex clobber=1 storable=0 \
	-- $(RAW_TREEX_DIR)/*.streex

clean_finetreex:
	rm -rf ./$(FINE_TREEX_DIR)/*

#	Misc::CopenhagenDT::MoveTreesToDanishCounterpartIfSameNumber \


#	Misc::CopenhagenDT::MoveDanishTreesToSeparateBundles \
#	Misc::CopenhagenDT::MoveTreesToDanishCounterpartIfSameNumber \
#	Misc::CopenhagenDT::MoveTreesToDanishCounterpartByAlignment \


# ----------------------------------------------

types:
	cat selection.log | grep SELE | cut -f2 | ./test_new_file_names.pl | sort | uniq -c | sort -nr > typefreq


segm:
	treex Misc::CopenhagenDT::ImportSentSegmFromExternalFiles cdt_root_dir=../../../ -- generated_raw_treex/*streex
