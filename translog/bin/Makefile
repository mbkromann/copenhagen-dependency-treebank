DIR="data"

all: clean copy events tokenTable totreex finetreex


copy:
	rm -rf data
	./CopyTrl.sh ACS08
	./CopyTrl.sh BD08
	./CopyTrl.sh BML12
	./CopyTrl.sh JLG10
	./CopyTrl.sh KTHJ08
	./CopyTrl.sh LWB09
	./CopyTrl.sh MS12
	./CopyTrl.sh NJ12
	./CopyTrl.sh SG12
	./CopyTrl.sh TPR11


events:
	./MergeEvents2Trl.sh ACS08
	./MergeEvents2Trl.sh BD08
	./MergeEvents2Trl.sh BML12
	./MergeEvents2Trl.sh JLG10
	./MergeEvents2Trl.sh KTHJ08
	./MergeEvents2Trl.sh LWB09
	./MergeEvents2Trl.sh MS12
	./MergeEvents2Trl.sh NJ12
	./MergeEvents2Trl.sh SG12
	./MergeEvents2Trl.sh TPR11


tokenTable:
	./Trl2TokenTables.sh ACS08
	./Trl2TokenTables.sh BD08
	./Trl2TokenTables.sh BML12
	./Trl2TokenTables.sh JLG10
	./Trl2TokenTables.sh KTHJ08
	./Trl2TokenTables.sh LWB09
	./Trl2TokenTables.sh MS12
	./Trl2TokenTables.sh NJ12
	./Trl2TokenTables.sh SG12
	./Trl2TokenTables.sh TPR11

totreex:
	mkdir -p data/$1/Treex 
	./ED12.ToTreex.sh

#	./Annette_translate.ToTreex.sh
#	./EN-Text1.ToTreex.sh
#	./EN-Text2.ToTreex.sh
#	./EN-Text3.ToTreex.sh
#	./EN-Text4.ToTreex.sh
#	./EN-Text5.ToTreex.sh
#	./EN-Text6.ToTreex.sh

finetreex:
	@echo ----------- Step 4: Refining the data in treex ----------
	mkdir -p $(DIR)/final
	treex \
	Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
        Misc::CopenhagenDT::MoveSLTreesToSeparateBundles \
	Misc::CopenhagenDT::MoveTLTreesToSLCounterpartByAlignment \
	Misc::CopenhagenDT::FixLonelyNodes \
        Misc::CopenhagenDT::DeleteFirstBundle \
        Misc::CopenhagenDT::FlattenUnannotatedTrees \
        Util::Eval document="\$$doc->set_path(qw($(DIR)/final))" \
        Write::Treex clobber=1 storable=0 \
        -- $(DIR)/Treex/ED12_*.treex.gz

TargetAUTable:
	rm -f data/TargetAUTables.tsv
	./Trl2TargetAUTables.sh ED12
	./Trl2TargetAUTables.sh Annette_translate
	./Trl2TargetAUTables.sh ED12
	./Trl2TargetAUTables.sh EN-DA
	./Trl2TargetAUTables.sh EN-ES
	./Trl2TargetAUTables.sh EN-HI
	./Trl2TargetAUTables.sh EN-ZH
	./Trl2TargetAUTables.sh Silke
	./Trl2TargetAUTables.sh L1L2
	./Trl2TargetAUTables.sh EN-DE_TPR-PE
	./Trl2TargetAUTables.sh EN-PT_TPR-PE


ProgGraphTable:
	./Trl2ProgGraphTables.sh Annette_translate
	./Trl2ProgGraphTables.sh ED12
	./Trl2ProgGraphTables.sh EN-DA
	./Trl2ProgGraphTables.sh EN-ES
	./Trl2ProgGraphTables.sh EN-ZH
	./Trl2ProgGraphTables.sh EN-HI
	./Trl2ProgGraphTables.sh Silke
	./Trl2ProgGraphTables.sh EN-DE_TPR-PE
	./Trl2ProgGraphTables.sh EN-PT_TPR-PE


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
