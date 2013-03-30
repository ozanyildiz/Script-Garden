#!/usr/bin/env python

import networkx as nx
import matplotlib.pyplot as plt

def shortest_path(graph, distance, previous, source):
    queue = []
    
    # Initialization of distance and previous
    for node in graph.nodes():
        distance[node] = None
        previous[node] = 0
    
    distance[source] = 0
    queue.append(source)

    while len(queue) != 0:
        v = queue.pop(0)
        for w in graph.neighbors(v):
            if distance[w] == None:
                previous[w] = v
                distance[w] = distance[v] + 1
                queue.append(w)

def get_path(t, previous):
    edges = []

    while previous[t] != 0:
        edges.append((t, previous[t]))
        t = previous[t]
        
    return edges

g = nx.Graph()
node_list = [1, 2, 3, 4, 5, 6]
edge_list = [(1, 2), (1, 5), (2, 4), (3, 1),
             (3, 5), (4, 6), (5, 6), (6, 2)]
g.add_edges_from(edge_list)

dist = {}
prev = {}

# Assumed that source is 3 and target is 6
src = 3
target = 6
shortest_path(g, dist, prev, src)
s_path = get_path(target, prev)

pos = nx.spring_layout(g)
nx.draw_networkx_nodes(g, pos, nodelist=node_list,
                       node_color='b', node_size=600)
nx.draw_networkx_edges(g, pos, edgelist=edge_list)
nx.draw_networkx_edges(g, pos, edgelist=s_path,
                       width=8, alpha=0.5, edge_color='r')

labels = {}
for i in range(1, 7):
    if i == src:
        labels[i] = r'$%d*$' % i
    else:
        labels[i] = r'$%d$' % i

nx.draw_networkx_labels(g, pos, labels, font_size=16)

plt.axis('off')
plt.show()


