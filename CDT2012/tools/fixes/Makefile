MASK=''

fixall:
	./remove_weird_xml_entities.pl $(MASK) #r1873
	./quote_xml_attributes_in_dag.pl $(MASK) # r1874
	./replace_unescaped_special_chars_by_entities.pl $(MASK) # 1877
	./add_root_element.pl $(MASK) # r1877
	./resolve_mismatchin_open_end_tags.pl $(MASK) # r1877
	./add_closing_tags.pl $(MASK) # r1878

revertall:
	svn revert ../../data/tag-format/*/*