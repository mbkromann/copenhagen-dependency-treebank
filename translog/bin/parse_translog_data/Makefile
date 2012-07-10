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

parse:
	treex --save tag_and_parse_en.scen -- parsed_sample/*treex.gz

transform:
	treex --save W2A::EN::RehangConllToPdtStyle \
	Misc::Translog::PdtStyleToCdtStyle \
	Misc::Translog::ProjectEdgesByAlignment \
	Misc::Translog::ConllDeprelToCdtDeprel -- parsed_sample/*treex.gz


clean:
	rm $(DIR) -rf
