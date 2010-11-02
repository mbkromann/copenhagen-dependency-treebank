# 	Finding strongly connected components (including cycles) with
# 	Tarjan's algorithm
#    
# 	DFS(G) {
# 		make a new vertex x with edges x => v for all v in G
# 		initialize a counter N to zero
# 		initialize list L to empty
# 		build directed tree T, initially a single vertex {x}
# 		visit(x)
#     }
# 
#     visit(p) {
# 		add p to L
# 		dfsnum(p) = N
# 		increment N
# 		low(p) = dfsnum(p)
# 		for each edge p->q
# 			if q is not already in T {
# 				add p->q to T
# 				visit(q)
# 				low(p) = min(low(p), low(q))
# 			} else low(p) = min(low(p), dfsnum(q))
# 
# 		if low(p)=dfsnum(p)
# 		{
# 			output "component:"
# 			repeat
# 				remove last element v from L
# 				output v
# 				remove v from G
# 			until v=p
# 		}
#     }
