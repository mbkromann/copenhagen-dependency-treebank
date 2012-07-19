DIR="data"

all: clean copy events tokenTable totreex fineTreex


copy:
	rm -rf data
	./CopyTrl.bash ACS08
	./CopyTrl.bash BD08
	./CopyTrl.bash BML12
	./CopyTrl.bash JLG10
	./CopyTrl.bash KTHJ08
	./CopyTrl.bash LWB09
	./CopyTrl.bash MS12
	./CopyTrl.bash NJ12
	./CopyTrl.bash SG12
	./CopyTrl.bash TPR11


events:
	./MergeEvents2Trl.bash ACS08
	./MergeEvents2Trl.bash BD08
	./MergeEvents2Trl.bash BML12
	./MergeEvents2Trl.bash JLG10
	./MergeEvents2Trl.bash KTHJ08
	./MergeEvents2Trl.bash LWB09
	./MergeEvents2Trl.bash MS12
	./MergeEvents2Trl.bash NJ12
	./MergeEvents2Trl.bash SG12
	./MergeEvents2Trl.bash TPR11


tokenTable:
	./Trl2TokenTables.bash ACS08
	./Trl2TokenTables.bash BD08
	./Trl2TokenTables.bash BML12
	./Trl2TokenTables.bash JLG10
	./Trl2TokenTables.bash KTHJ08
	./Trl2TokenTables.bash LWB09
	./Trl2TokenTables.bash MS12
	./Trl2TokenTables.bash NJ12
	./Trl2TokenTables.bash SG12
	./Trl2TokenTables.bash TPR11

singleTreex:
	mkdir -p data/$1/Treex 
	./ToSingleTreex.bash ACS08
	./ToSingleTreex.bash BD08
	./ToSingleTreex.bash BML12
	./ToSingleTreex.bash JLG10
	./ToSingleTreex.bash KTHJ08
	./ToSingleTreex.bash LWB09
	./ToSingleTreex.bash MS12
	./ToSingleTreex.bash NJ12
	./ToSingleTreex.bash SG12
	./ToSingleTreex.bash TPR11

multipleTreex:
	mkdir -p data/$1/Treex 
	./ToSingleTreex.bash ACS08
	./ToSingleTreex.bash BD08
	./ToSingleTreex.bash BML12
	./ToSingleTreex.bash JLG10
	./ToSingleTreex.bash KTHJ08
	./ToSingleTreex.bash LWB09
	./ToSingleTreex.bash MS12
	./ToSingleTreex.bash NJ12
	./ToSingleTreex.bash SG12
	./ToSingleTreex.bash TPR11

fineTreex:
	@echo ----------- Step 4: Refining the data in treex ----------
	mkdir -p $(DIR)/final
	treex \
	Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
        Misc::CopenhagenDT::MoveSLTreesToSeparateBundles \
	Misc::CopenhagenDT::MoveTLTreesToSLCounterpartByAlignment \
	Misc::CopenhagenDT::FixLonelyNodes \
        Misc::CopenhagenDT::DeleteFirstBundle \
        Misc::CopenhagenDT::FlattenUnannotatedTrees \
        Util::Eval document="\$$doc->set_path(qw($(DIR)/Treex))" \
        Write::Treex clobber=1 storable=0 \
        -- $(DIR)/Treex/raw/*.treex.gz

treex2alignment:
	treex \
	Misc::Translog::Treex2Alignment \
	-- $(DIR)/final/*.treex.gz

testToTreex:
	mkdir -p data/$1/Treex 
	./DevelopingCountries.ToTreex.bash

testFineTreex:
	@echo ----------- Step 4: Refining the data in treex ----------
	mkdir -p $(DIR)/final
	treex \
	Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
	Util::Eval document="\$$doc->set_path(qw($(DIR)/Treex))" \
	Write::Treex clobber=1 storable=0 \
	-- $(DIR)/Treex/raw/Developing*.treex.gz


TargetAUTable:
	rm -f data/TargetAUTables.tsv
	./Trl2TargetAUTables.bash ED12
	./Trl2TargetAUTables.bash Annette_translate
	./Trl2TargetAUTables.bash ED12
	./Trl2TargetAUTables.bash EN-DA
	./Trl2TargetAUTables.bash EN-ES
	./Trl2TargetAUTables.bash EN-HI
	./Trl2TargetAUTables.bash EN-ZH
	./Trl2TargetAUTables.bash Silke
	./Trl2TargetAUTables.bash L1L2
	./Trl2TargetAUTables.bash EN-DE_TPR-PE
	./Trl2TargetAUTables.bash EN-PT_TPR-PE


ProgGraphTable:
	./Trl2ProgGraphTables.bash Annette_translate
	./Trl2ProgGraphTables.bash ED12
	./Trl2ProgGraphTables.bash EN-DA
	./Trl2ProgGraphTables.bash EN-ES
	./Trl2ProgGraphTables.bash EN-ZH
	./Trl2ProgGraphTables.bash EN-HI
	./Trl2ProgGraphTables.bash Silke
	./Trl2ProgGraphTables.bash EN-DE_TPR-PE
	./Trl2ProgGraphTables.bash EN-PT_TPR-PE


search:
	treex \
	Misc::CopenhagenDT::SearchSwitched \
	Misc::CopenhagenDT::SearchFeaturesPrint \
	-- $(DIR)/final/ED12_*.treex.gz

segment:
	treex --save Misc::Translog::SegmentSentences Misc::Translog::MergeSentencesByAlignment -- $(DIR)/*treex.gz

parse:
	treex --save tag_and_parse_en.scen -- parsed_sample/*treex.gz

transform:
	treex --save W2A::EN::RehangConllToPdtStyle \
	Misc::Translog::PdtStyleToCdtStyle totreex \
	Misc::Translog::ProjectEdgesByAlignment \
	Misc::Translog::ConllDeprelToCdtDeprel -- parsed_sample/*treex.gz

clean:
	rm $(DIR) -rf
