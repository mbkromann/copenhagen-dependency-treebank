DIR="data"

all: clean merge_atag_trl totreex finetreex


copy:
	mkdir -p $(DIR)/EN-ES
	mkdir -p $(DIR)/EN-DA
	mkdir -p $(DIR)/EN-HI
	mkdir -p $(DIR)/EN-DE_TPR-PE
	mkdir -p $(DIR)/EN-PT_TPR-PE
	mkdir -p $(DIR)/L1L2
	mkdir -p $(DIR)/ED12
	mkdir -p $(DIR)/Annette_translate

	#cp -r ../../{Annette_translate,ED12,L1L2,EN-DA,EN-ES}/{Translog-II,Alignment}/* $(DIR)/

	exit
	cp -r ../../Annette_translate/* $(DIR)/Annette_translate
	cp -r ../../EN-DE_TPR-PE/* $(DIR)/EN-DE_TPR-PE 
	cp -r ../../EN-PT_TPR-PE/* $(DIR)/EN-PT_TPR-PE
	cp -r ../../ED12/* $(DIR)/ED12 
	cp -r ../../L1L2/* $(DIR)/L1L2
	cp -r ../../EN-DA/* $(DIR)/EN-DA 
	cp -r ../../EN-ES/* $(DIR)/EN-DA 
#	cp -r ../../EN-DA/* $(DIR)/EN-DA 

#	cp -r ../../L1L2/Translog-II/ $(DIR)/L1L2/Translog-II
#	cp -r ../../L1L2/Alignment/ $(DIR)/L1L2/Alignment
#	cp -r ../../EN-DA/Translog-II/ $(DIR)/EN-DA/Translog-II
#	cp -r ../../EN-DA/Alignment/ $(DIR)/EN-DA/Alignment
#	cp -r ../../EN-ES/Translog-II $(DIR)/EN-ES/Translog-II
#	cp -r ../../EN-ES/Alignment $(DIR)/EN-ES/Alignment
#	cp -r ../../EN-HI/Translog-II $(DIR)/EN-HI/Translog-II
#	cp -r ../../EN-HI/Alignment $(DIR)/EN-HI/Alignment

merge_atag_trl:
	./MergeAtagTrl.bash EN-HI

finetreex:
	@echo ----------- Step 4: Refining the data in treex ----------
	mkdir -p $(DIR)/final
	treex \
	Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
	Misc::CopenhagenDT::ReconstructAlignmentLinks \
        Misc::CopenhagenDT::ImportSentSegmFromExternalFiles cdt_root_dir=../../../ \
        Misc::CopenhagenDT::SentSegmByTagS \
        Misc::CopenhagenDT::MoveDanishTreesToSeparateBundles \
        Misc::CopenhagenDT::MoveTreesToDanishCounterpartByAlignment \
        Misc::CopenhagenDT::MoveTreesToDanishCounterpartBySizeSimilarity \
        Misc::CopenhagenDT::FixLonelyNodes \
        Misc::CopenhagenDT::FlattenUnannotatedTrees \
        Util::Eval document="\$$doc->set_path(qw($(DIR)/final))" \
        Write::Treex clobber=1 storable=0 \
        -- $(DIR)/Treex/*.treex.gz

        #Misc::CopenhagenDT::DeleteFirstBundle \

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
