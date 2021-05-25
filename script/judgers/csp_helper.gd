extends Node

var binomial = null
const BINOMIAL_LIMIT = 100000000
func get_binomial(i, j):
	if (binomial == null):
		binomial = []
		for k in range(1000):
			binomial.append([])
			for l in range(k + 1):
				if (l == 0 or l == k):
					binomial[k].append(1.0)
				else:
					var result = binomial[k - 1][l] + binomial[k - 1][l - 1]
					result = min(result, BINOMIAL_LIMIT + k)
					binomial[k].append(result)
	if (j > i or j < 0):
		return 0
	if (j == 0 or j == i):
		return 1
	if (i < 1000):
		return binomial[i][j]
	return BINOMIAL_LIMIT + i
