DIR="data"

all: clean copy merge_atag_trl totreex finetreex


copy:
	./CopyTrl.bash Annette_translate
	./CopyTrl.bash ED12
	./CopyTrl.bash EN-DA
	./CopyTrl.bash EN-DA
	./CopyTrl.bash EN-ES
	./CopyTrl.bash EN-HI
	./CopyTrl.bash EN-DE_TPR-PE
	./CopyTrl.bash EN-PT_TPR-PE


merge_atag_trl:
	./MergeAtagTrl.bash Annette_translate
	./MergeAtagTrl.bash ED12
	./MergeAtagTrl.bash EN-DA
	./MergeAtagTrl.bash EN-DA
	./MergeAtagTrl.bash EN-ES
	./MergeAtagTrl.bash EN-HI
	./MergeAtagTrl.bash EN-DE_TPR-PE
	./MergeAtagTrl.bash EN-PT_TPR-PE


totreex:
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
        Util::Eval document="\$$doc->set_path(qw($(DIR)/final))" \
        Write::Treex clobber=1 storable=0 \
        -- $(DIR)/Treex/ED12_Parse.treex.gz

#        -- $(DIR)/Treex/*.treex.gz

        #Misc::CopenhagenDT::FixLonelyNodes \
        #Misc::CopenhagenDT::DeleteFirstBundle \
        #Misc::CopenhagenDT::FlattenUnannotatedTrees \
        #Misc::CopenhagenDT::MoveTreesToDanishCounterpartByAlignment \
        #Misc::CopenhagenDT::MoveTreesToDanishCounterpartBySizeSimilarity \
	#Misc::CopenhagenDT::ReconstructAlignmentLinks \
        #Misc::CopenhagenDT::ImportSentSegmFromExternalFiles cdt_root_dir=../../../ \
        #Misc::CopenhagenDT::SentSegmByTagS \

test:
	treex --save Misc::Translog::MergeSentencesByAlignment -- $(DIR)/Treex/ED12.treex.gz

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
