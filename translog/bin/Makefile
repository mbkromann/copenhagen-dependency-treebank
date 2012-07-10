DIR="data"

all: clean copy events totreex finetreex


copy:
	rm -rf data
	./CopyTrl.sh Annette_translate
	./CopyTrl.sh ED12
	./CopyTrl.sh EN-DA
	./CopyTrl.sh EN-ES
	./CopyTrl.sh EN-HI
	./CopyTrl.sh EN-ZH
	./CopyTrl.sh Silke
	./CopyTrl.sh L1L2
	./CopyTrl.sh EN-DE_TPR-PE
	./CopyTrl.sh EN-PT_TPR-PE


events:
	./MergeEvents2Trl.sh Annette_translate
	./MergeEvents2Trl.sh ED12
	./MergeEvents2Trl.sh EN-DA
	./MergeEvents2Trl.sh EN-ES
	./MergeEvents2Trl.sh EN-HI
	./MergeEvents2Trl.sh EN-ZH
	./MergeEvents2Trl.sh Silke
	./MergeEvents2Trl.sh L1L2
	./MergeEvents2Trl.sh EN-DE_TPR-PE
	./MergeEvents2Trl.sh EN-PT_TPR-PE


totreex:
	mkdir -p data/$1/Treex 
	./Annette_translate.ToTreex.sh
	./ED12.ToTreex.sh
	./EN-Text1.ToTreex.sh
	./EN-Text2.ToTreex.sh
	./EN-Text3.ToTreex.sh
	./EN-Text4.ToTreex.sh
	./EN-Text5.ToTreex.sh
	./EN-Text6.ToTreex.sh

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


TokenTable:
	./Trl2TokenTables.sh Annette_translate
	./Trl2TokenTables.sh ED12
	./Trl2TokenTables.sh EN-DA
	./Trl2TokenTables.sh EN-ES
	./Trl2TokenTables.sh EN-HI
	./Trl2TokenTables.sh EN-ZH
	./Trl2TokenTables.sh Silke
	./Trl2TokenTables.sh L1L2
	./Trl2TokenTables.sh EN-DE_TPR-PE
	./Trl2TokenTables.sh EN-PT_TPR-PE

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
