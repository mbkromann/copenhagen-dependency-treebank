help:
	@echo "Conversion of Copenhagen Dependency Treebank .tag and .atag files"
	@echo " into the treex format. Written by Zdenek Zabokrtsky"
	@echo
	@echo "The conversion consists of four steps. You can run it all"
	@echo "(by typing 'make all'), or step by step. The names of the steps are"
	@echo "  select - select .tag and .atag files for conversion"
	@echo "  xmlize - convert the .tag and .atag files to well-formed and valid XML"
	@echo "  rawtreex - convert data into treex, without decoding the structures"
	@echo "  finetreex - reprezent the data in proper treex attributes"
	@echo
	@echo "These four names, and the special value 'all', "
	@echo "are the possible values of the STEP placeholder used below."
	@echo
	@echo "Type 'make run_STEP' to execute a particular step STEP. "
	@echo
	@echo "Type 'make test_STEP' to check the output of a step STEP."
	@echo
	@echo "Type 'make stat_STEP' to extract statistics from files generated during a step STEP."
	@echo 
	@echo "Type 'make clean_STEP' to remove all files generated in a step STEP."
	@echo
	@echo "You can use argument NUMBER to restrict the procedure only to a certain file number."
	@echo "Example:  "
	@echo "  make run_select run_xmlize test_xmlize NUMBER=005"

# -------------------------------------------------------------------------------------

NUMBER=
INDIR=../../
OUTDIR=./data
LOGDIR=./log


run_all: run_select run_xmlize run_rawtreex run_finetreex

# -------------------------------------------------------------------------------------

run_select:
	mkdir -p $(OUTDIR)/select
	mkdir -p $(LOGDIR)/select
	./scripts_for_select/select_tag_files.pl --number=$(NUMBER) --indir=$(INDIR) --outdir=$(OUTDIR)/select > $(LOGDIR)/select/select.log

clean_select:
	rm outdir=$(OUTDIR)/select -rf
	rm outdir=$(LOGDIR)/log -rf