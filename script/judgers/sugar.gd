extends Node

var n_bools: int
var n_ints: int
var constraints: Array
const TRUE = 'true'
const FALSE = 'false'
const ZERO = '0'
const ONE = '1'
var keys: Array
var int_lows: Array
var int_highs: Array

func new_bool(is_key=false):
	var result = "b" + str(n_bools)
	if (is_key):
		keys.append(result)
	n_bools += 1
	return result
	
func new_int(low, high, is_key=false):
	var result = "i" + str(n_ints)
	if (is_key):
		keys.append(result)
	int_lows.append(low)
	int_highs.append(high)
	n_ints += 1
	return result

func new_bool_array(size, is_key=false):
	var result = []
	for i in range(size):
		result.append(new_bool(is_key))
	return result
	
func new_int_array(size, low, high, is_key=false):
	var result = []
	for i in range(size):
		result.append(new_int(low, high, is_key))
	return result
	
	
func binary_operator(op, lhs, rhs):
	if (lhs is Array and rhs is Array):
		var result = []
		for i in range(len(lhs)):
			result.append(binary_operator(op, lhs[i], rhs[i]))
		return result
	elif (lhs is Array):
		var result = []
		for i in range(len(lhs)):
			result.append(binary_operator(op, lhs[i], rhs))
		return result
	elif (rhs is Array):
		var result = []
		for i in range(len(rhs)):
			result.append(binary_operator(op, lhs, rhs[i]))
		return result
	else:
		return '(%s %s %s)' % [op, lhs, rhs]

func unary_operator(op, rhs):
	if (rhs is Array):
		var result = []
		for i in range(len(rhs)):
			result.append(unary_operator(op, rhs[i]))
		return result
	else:
		return '(%s %s)' % [op, rhs]
		
func add(lhs, rhs):
	return binary_operator('+', lhs, rhs)
	
func sub(lhs, rhs):
	return binary_operator('-', lhs, rhs)

func neg(rhs):
	return unary_operator('-', rhs)
	
func eq(lhs, rhs):
	return binary_operator('=', lhs, rhs)
	
func neq(lhs, rhs):
	return binary_operator('!=', lhs, rhs)
	
func leq(lhs, rhs):
	return binary_operator('<=', lhs, rhs)
	
func lt(lhs, rhs):
	return binary_operator('<', lhs, rhs)
	
func geq(lhs, rhs):
	return binary_operator('>=', lhs, rhs)
	
func ge(lhs, rhs):
	return binary_operator('>', lhs, rhs)

func not_(rhs):
	return unary_operator('!', rhs)
	
func and_(lhs, rhs):
	return binary_operator('&&', lhs, rhs)
	
func fold_and(args: Array):
	if (len(args) == 0):
		return TRUE
	return '(&& %s)' % PoolStringArray(args).join(' ')
	
func or_(lhs, rhs):
	return binary_operator('||', lhs, rhs)
	
func fold_or(args: Array):
	if (len(args) == 0):
		return FALSE
	return '(|| %s)' % PoolStringArray(args).join(' ')

func iff(lhs, rhs):
	return binary_operator('iff', lhs, rhs)
	
func xor(lhs, rhs):
	return binary_operator('xor', lhs, rhs)
	
func imp(lhs, rhs):
	return binary_operator('=>', lhs, rhs)

func if_(lhs, t, f):
	return '(if %s %s %s)' % [lhs, t, f] 

func to_int(boolean):
	return if_(boolean, ONE, ZERO)
	
func count_true(args):
	if (len(args) == 0):
		return ZERO
	var results = []
	for arg in args:
		results.append(to_int(arg))
	return '(+ %s)' % PoolStringArray(results).join(' ')

func graph_vertex_connected(vertices, edges):
	var edge_result = []
	var n_vertices = len(vertices)
	var n_edges = len(edges)
	for edge in edges:
		edge_result.append(str(edge[0]))
		edge_result.append(str(edge[1]))
	return '(graph-active-vertices-connected %d %d %s %s)' % [
		n_vertices, n_edges, PoolStringArray(vertices).join(' '),
		PoolStringArray(edge_result).join(' ')
	]

func ensure(expr):
	if (expr is Array):
		for item in expr:
			ensure(item)
	else:
		# print('Added constraint:', expr)
		constraints.append(expr)

func solve(n_solutions=-1):
	var desc = []
	for i in range(n_bools):
		desc.append('(bool b%d)' % i)
	for i in range(n_ints):
		desc.append('(int i%d %d %d)' % [i, int_lows[i], int_highs[i]])
	for constraint in constraints:
		desc.append(constraint)
	desc.append('#%s' % PoolStringArray(keys).join(' '))
	desc.append('$%d' % n_solutions)
	var desc_string = PoolStringArray(desc).join('\n')
	var file = File.new()
	file.open("D:/temp/test.in", file.WRITE)
	file.store_string(desc_string)
	file.close()
	var output = []
	var solutions = []
	OS.execute('D:/temp/csugar.exe', ['<', 'D:/temp/test.in'], true, output, true)
	if (len(output) != 1):
		print('Error: solver failed')
	else:
		output = output[0].replace('\r', '').split('\n')
		if (output[0] == 'unsat'):
			return solutions
		else:
			var solution = {}
			for line in output:
				if (line == 'unsat'):
					return solutions
				if (line.begins_with('ans ') or line == ''):
					continue
				elif (line == '$'):
					solutions.append(solution)
					solution = {}
				else:
					var tokens = line.split(' ')
					solution[tokens[0]] = int(tokens[1]) if tokens[0].begins_with('i') else (tokens[1] == 'true')
			return solutions
			
