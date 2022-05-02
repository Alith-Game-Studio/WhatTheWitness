extends Node

func parse_xml_file(file):
	var parser = XMLParser.new()
	var error
	if ('[?]' in file):
		var generated_str = Generator.GeneratePanel(file, Gameplay.challenge_seed)
		error = parser.open_buffer(generated_str.to_utf8())
	else:
		error = parser.open(file)
	var result = {}
	if (error):
		print('Cannot open file %s' % file)
		return result
	while true:
		error = parser.read()
		if (error):
			print('Error while reading %s' % file)
			return result
		var node_name = parser.get_node_name()
		if (node_name.begins_with('?xml')):
			continue
		var node_type = parser.get_node_type()
		if (node_type == XMLParser.NODE_ELEMENT):
			return read_node(parser, node_name)
		else:
			assert(false)
		
func read_node(parser, node_name):
	var result = {'_arr': []}
	for i in range(parser.get_attribute_count()):
		result[parser.get_attribute_name(i)] = parser.get_attribute_value(i) 
	if (!parser.is_empty()):
		while true:
			var error = parser.read()
			if (error):
				print('Error while reading XML node %s' % node_name)
				return result
			if (node_name.begins_with('?xml')):
				continue
			var sub_node_type = parser.get_node_type()
			if (sub_node_type == XMLParser.NODE_ELEMENT_END):
				var sub_node_name = parser.get_node_name()
				assert(sub_node_name == node_name)
				break
			elif (sub_node_type == XMLParser.NODE_ELEMENT):
				var sub_node_name = parser.get_node_name()
				var element = read_node(parser, sub_node_name)
				result[sub_node_name] = element
				result['_arr'].append(element)
			elif (sub_node_type == XMLParser.NODE_TEXT):
				var text = parser.get_node_data().strip_edges(true, true)
				if (text != ''):
					result['_text'] = text
			elif (sub_node_type == XMLParser.NODE_COMMENT):
				continue
			else:
				assert(false)
	if (result['_arr'].empty() and result.has('_text')):
		return result['_text']
	else:
		return result
	
