# Load graph library
library(graph)
library(Rgraphviz)

# Load edge table and remove templates
cdt <- read.csv("cdt-relations.csv")
cdt2 <- cdt[cdt$Unique != "" & regexpr("\\$", cdt$Unique.short.name) == -1,]

# Extract nodes and print out non-unique node names
nodes <- as.character(cdt2$Unique.short.name)
counts <- rle(sort(nodes))
cat("Non-unique node names\n")
print(counts$values[counts$lengths > 1])

# Extract edges and split into lists
edges <- as.pairlist(strsplit(as.character(cdt2$Super.types), "\\s+", perl=T))
names(edges) = nodes
#edges[! edges %in% nodes]

# Create graph
cdtgraph <- new("graphNEL", nodes, edges, "directed")

plot(cdtgraph, "twopi", 
	fontsize=20,
	attrs=list(
		graph=list(),
		node=makeNodeAttrs(cdtgraph, 
			labelFontsize=20, 
			#labelFontsize=10, width=1,height=0.1,
			label=nodes(cdtgraph), shape="plaintext"),
		edge=list(arrowsize=0, headclip=FALSE, color="#aaaaaa", tailclip=FALSE, len=0.5,lwd=0.5)#len=7, lwd=0.5)
	))
		
