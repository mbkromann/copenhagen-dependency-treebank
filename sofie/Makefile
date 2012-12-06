sofie-ddt.xml: sofie-ddt.tag
	sed -e 's/msd="\([^"][^"]\)/cat="\1" msd="\1/' sofie-ddt.tag \
		> /tmp/sofie.tag
	dtag -e 'load /tmp/sofie.tag ; layout -vars /stream:.*|cat|msd|lemma|_position ; layout -var msd ; save sofie-ddt.xml ; exit'

