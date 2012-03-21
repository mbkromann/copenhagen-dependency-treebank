DIR="data"

all: clean copy convert_encoding totreex segment


copy:
	mkdir -p $(DIR)
	cp ../../translog/Kristian24/* $(DIR)

convert_encoding:
	./convert_encoding.sh

totreex:
	./translog2treex.pl

segment:
	treex --save Misc::Translog::SegmentSentences Misc::Translog::MergeSentencesByAlignment -- $(DIR)/*treex.gz


clean:
	rm $(DIR) -rf
