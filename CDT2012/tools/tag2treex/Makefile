NUMBER=0104

test:	conv1 conv2


conv1:
	./tag2treex.pl ../../data/tag-format/??/$(NUMBER)*tag  ../../data/tag-format/??-??/$(NUMBER)*atag > tmp

conv2:
	treex --save  \
	Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
	Misc::CopenhagenDT::ReconstructAlignmentLinks \
	Misc::CopenhagenDT::MoveDanishTreesToSeparateBundles \
	Misc::CopenhagenDT::MoveTreesToDanishCounterpartIfSameNumber \
	Misc::CopenhagenDT::MoveTreesToDanishCounterpartByAlignment \
	-- *.treex.gz

tuples:
	treex Misc::CopenhagenDT::CreateBundlePerSentenceTuple -- test.treex.gz


all:
	./tag2treex.pl ../../data/tag-format/??/*tag > tmp

clean:
	rm *.treex.gz