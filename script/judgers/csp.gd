extends Node

class CSPClause:
	
	var sum: int
	var variables: Dictionary # Variable -> (+1, -1) coef
	var positive_count: int
	var negative_count: int
	var assigned_variables: Dictionary # Variable -> (+1, -1) coef
	
	func get_weight(): # -1: satisfied 0: unsatisfiable >0: possibilities
		var variable_count = len(variables)
		if (variable_count == 0 and sum == 0):
			return -1
		var max_eq = min(positive_count, negative_count + sum)
		var min_eq = max(0, sum)
		if (max_eq < min_eq):
			return 0
		# use approximation here
		var eq = (max_eq + min_eq) / 2
		var lhs_result = CSPHelper.get_binomial(positive_count, eq)
		var rhs_result = CSPHelper.get_binomial(negative_count, eq - sum)
		if (float(lhs_result) * rhs_result * (max_eq - min_eq + 1) > 1e8):
			# prevent overflow and return a huge number
			return CSPHelper.BINOMIAL_LIMIT + lhs_result + rhs_result
		else:
			return lhs_result * rhs_result * (max_eq - min_eq + 1)
			
	func unlink(x, value):
		assert(x in variables)
		assert(!(x in assigned_variables))
		var coef = variables[x]
		assert(coef in [-1, 1])
		if (coef == 1):
			positive_count -= 1
		else:
			negative_count -= 1
		sum -= coef * value
		variables.erase(x)
		assigned_variables[x] = [coef, value]
		
	func relink(x):
		assert(!(x in variables))
		assert(x in assigned_variables)
		var coef_value = assigned_variables[x]
		var coef = coef_value[0]
		var value = coef_value[1]
		if (coef == 1):
			positive_count += 1
		else:
			negative_count += 1
		sum += coef * value
		variables[x] = coef
		assigned_variables.erase(x)
			
class CSPVariable:
	
	var clauses: Array # of clauses
	var value = -1

class CSPSolver:
	
	var clauses: Array # of Clause
	var weight_dict: Dictionary # int -> int
	var variables: Array # of dictionary
	
	func add_clause(variable_coef_map, sum):
		var clause = CSPClause.new()
		clause.sum = sum
		for variable in variable_coef_map:
			var coef = variable_coef_map[variable]
			assert(coef in [-1, 1])
			clause.variables[variable] = coef
			if (coef == 1):
				clause.positive_count += 1
			else:
				clause.negative_count += 1
		var clause_id = len(clauses)
		var weight = clause.get_weight()
		clauses.append(clause)
		weight_dict[clause_id] = weight
		for variable in variable_coef_map:
			while (variable >= len(variables)):
				variables.append(CSPVariable.new())
			variables[variable].clauses.append(clause_id)
	
	func update_weight(clause_id):
		var weight = clauses[clause_id].get_weight()
		# print('C%d has new weight %d' % [clause_id, weight] )
		if (weight == -1):
			weight_dict.erase(clause_id)
		else:
			weight_dict[clause_id] = weight
		return weight
	
	func satisfiable():
		# print('Searching!')
		if (weight_dict.empty()):
			# print('Ok!')
			return true
		var min_weight = -1
		var min_id = -1
		for id in weight_dict:
			var weight = weight_dict[id]
			if (min_weight > weight or min_id == -1):
				min_id = id
				min_weight = weight
		for variable in clauses[min_id].variables:
			for assignment in [1, 0]:
				var ok = true
				# print('Set v%d to %d' % [variable, assignment])
				variables[variable].value = assignment
				for affected_clause in variables[variable].clauses:
					clauses[affected_clause].unlink(variable, assignment)
				for affected_clause in variables[variable].clauses:
					var new_weight = update_weight(affected_clause)
					if (new_weight == 0):
						# print('Clause %d failed!' % affected_clause)
						ok = false
						break
				if (ok):
					ok = satisfiable()
				for affected_clause in variables[variable].clauses:
					clauses[affected_clause].relink(variable)
					update_weight(affected_clause)
				if (ok):
					return true
				variables[variable].value = -1
				# print('Unset v%d from %d' % [variable, assignment])
			break
		return false
			
		
func test():
	var solver = CSPSolver.new()
	solver.add_clause({0: 1, 1: 1, 2: -1}, 2)
	print(solver.satisfiable())
	for i in range(len(solver.variables)):
		print('v%d: %d' % [i, solver.variables[i].value])
	# solution: [1, 1, 0]
	
	solver = CSPSolver.new()
	solver.add_clause({2: 1, 4: 1}, 1)
	solver.add_clause({3: 1, 5: 1}, 1)
	solver.add_clause({1: 1, 3: 1}, 1)
	solver.add_clause({2: 1, 4: 1, 6: 1}, 1)
	solver.add_clause({1: 1, 6: 1}, 1)
	solver.add_clause({1: 1, 3: 1}, 1)
	solver.add_clause({2: 1, 5: 1, 6: 1}, 1)
	print(solver.satisfiable())
	for i in range(len(solver.variables)):
		print('v%d: %d' % [i, solver.variables[i].value])
	# solution: [-1, 1, 0, 0, 1, 1, 0]
