from xml.etree.ElementTree import parse

def get_region_id(x, y):
    if (x < 6.5):
        return [0, 1][y > 6.5]
    elif (x < 12.5):
        return [2, 3][y > 6.5]
    else:
        return [4, 5][y > 6.5]


def process_file(input_path, num, output_path):
    content = parse(input_path)
    nodes_node = content.find('Nodes')
    edges_node = content.find('EdgesID')
    facets_node = content.find('FacesID')
    nodes_list = nodes_node.findall('Node')
    edges_list = edges_node.findall('SaveEdge')
    facets_list = facets_node.findall('SaveFace')
    discard_node_ids = set()
    discard_nodes = []
    id_remap = []
    current_id = 0
    for i, node in enumerate(nodes_list):
        x, y = float(node.findtext('X')), float(node.findtext('Y'))
        if (get_region_id(x, y) >= num):
            discard_node_ids.add(i)
            discard_nodes.append(node)
            id_remap.append(-1)
        else:
            id_remap.append(current_id)
            current_id += 1
    for node in discard_nodes:
        nodes_node.remove(node)
    discard_edges = []
    for edge in edges_list:
        s, t = int(edge.findtext('Start')), int(edge.findtext('End'))
        if (s in discard_node_ids or t in discard_node_ids):
            discard_edges.append(edge)
        else:
            edge.find('Start').text = str(id_remap[s])
            edge.find('End').text = str(id_remap[t])
    for edge in discard_edges:
        edges_node.remove(edge)
    discard_facets = []
    for facet in facets_list:
        node_ids = facet.find('Nodes').findall('int')
        for i in node_ids:
            if (int(i.text) in discard_node_ids):
                discard_facets.append(facet)
                break
            else:
                i.text = str(id_remap[int(i.text)])
    for facet in discard_facets:
        facets_node.remove(facet)
    content.write(output_path, encoding="UTF-8")
if __name__ == '__main__':
    for file in ['wc7-H01', 'wc7-H02']:
        for n in [1, 2, 3, 4, 5]:
            process_file(file + '.wit', n, '%s-%d.wit' % (file, n))