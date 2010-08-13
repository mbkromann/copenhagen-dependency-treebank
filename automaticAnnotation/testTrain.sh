#!/bin/bash

#$ -S /bin/bash

java -classpath "/srv/tools/mstparser:/srv/tools/mstparser/lib/trove.jar" -Xmx8192m mstparser.DependencyParser train train-file:it-0.train.conll order:2 decode-type:non-proj model-name:it-0.model
