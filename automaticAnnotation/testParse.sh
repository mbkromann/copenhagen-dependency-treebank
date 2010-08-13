#!/bin/bash

#$ -S /bin/bash

java -classpath "/srv/tools/mstparser:/srv/tools/mstparser/lib/trove.jar" -Xmx8192m mstparser.DependencyParser test test-file:it-0.test.conll output-file:it-0.test.out.conll order:2 decode-type:non-proj model-name:it-0.model
