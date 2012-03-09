test:	conv1 conv2


conv1:
	./tag2treex.pl ../../data/tag-format/??/0001*tag > tmp

conv2:
	treex --save Misc::CopenhagenDT::BuildTreesFromOffsetIndices -- test.treex.gz

tuples:
	treex Misc::CopenhagenDT::CreateBundlePerSentenceTuple -- test.treex.gz


all:
	./tag2treex.pl ../../data/tag-format/??/*tag > tmp
