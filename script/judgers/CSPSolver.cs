using Godot;
using System;
using System.Collections.Generic;

class CSPHelper : Node {

    public const int BINOMIAL_LIMIT = 100000000;
    const int MAX_SIZE = 1000;
    static int[,] binomial;
    static CSPHelper() {
        binomial = new int[MAX_SIZE, MAX_SIZE];
        for (int k = 0; k < MAX_SIZE; ++k) {
            for (int l = 0; l <= k; ++l) {
                if (l == 0 || l == k)
                    binomial[k, l] = 1;
                else {
                    int result = binomial[k - 1, l] + binomial[k - 1, l - 1];
                    binomial[k, l] = Math.Min(result, BINOMIAL_LIMIT + k);
                }
            }
        }
    }
    public static int GetBinomial(int i, int j) {
        if (j > i || j < 0)
            return 0;
        if (j == 0 || j == i)
            return 1;
        if (i < MAX_SIZE)
            return binomial[i, j];
        return BINOMIAL_LIMIT + i;
    }
}
class CSPClause : Node {
    public int sum;
    public Dictionary<int, int> variables = new Dictionary<int, int>();
    public int positiveCount;
    public int negativeCount;
    public Dictionary<int, (int, int)> assignedVariables = new Dictionary<int, (int, int)>();
    public int GetWeight() {
        if (variables.Count == 0 && sum == 0)
            return -1;
        int maxEq = Math.Min(positiveCount, negativeCount + sum);
        int minEq = Math.Max(0, sum);
        if (maxEq < minEq)
            return 0;
        // use approximation here
        int eq = (maxEq + minEq) / 2;
        int lhsResult = CSPHelper.GetBinomial(positiveCount, eq);
        int rhsResult = CSPHelper.GetBinomial(negativeCount, eq - sum);
        if ((float)lhsResult * rhsResult * (maxEq - minEq + 1) > 1e8)
            // prevent overflow and return a huge number
            return CSPHelper.BINOMIAL_LIMIT + lhsResult + rhsResult;
        else
            return lhsResult * rhsResult * (maxEq - minEq + 1);
    }
    public void Unlink(int x, int value) {
        int coef = variables[x];
        if (coef == 1)
            positiveCount -= 1;
        else
            negativeCount -= 1;
        sum -= coef * value;
        variables.Remove(x);
        assignedVariables[x] = (coef, value);
    }
    public void Relink(int x) {
        (int coef, int value) = assignedVariables[x];
        if (coef == 1)
            positiveCount += 1;
        else
            negativeCount += 1;
        sum += coef * value;
        variables[x] = coef;

        assignedVariables.Remove(x);
    }
}
class CSPVariable : Node {
    public List<int> clauses = new List<int>();
    public int value;
}
public class CSPSolver : Node {
    List<CSPClause> clauses = new List<CSPClause>();
    Dictionary<int, int> weightDict = new Dictionary<int, int>();
    List<CSPVariable> variables = new List<CSPVariable>();
    public void Clear() {
        clauses.Clear();
        weightDict.Clear();
        variables.Clear();
    }
    public void AddClause(Dictionary<int, int> variableCoefMap, int sum) {
        CSPClause clause = new CSPClause();
        clause.sum = sum;
        foreach (KeyValuePair<int, int> kv in variableCoefMap) {
            int variable = kv.Key;
            int coef = kv.Value;
            clause.variables[variable] = coef;
            if (coef == 1)
                clause.positiveCount += 1;
            else
                clause.negativeCount += 1;
        }
        int clauseId = clauses.Count;
        int weight = clause.GetWeight();
        clauses.Add(clause);
        if (weight != -1) // -1 means already satisfied (empty clause 0 = 0)
            weightDict[clauseId] = weight;
        foreach (KeyValuePair<int, int> kv in variableCoefMap) {
            int variable = kv.Key;
            while (variable >= variables.Count)
                variables.Add(new CSPVariable());
            variables[variable].clauses.Add(clauseId);
        }
    }
    int UpdateWeight(int clauseId) {
        var weight = clauses[clauseId].GetWeight();
        if (weight == -1)
            weightDict.Remove(clauseId);
        else
            weightDict[clauseId] = weight;
        return weight;
    }
    void PrintSolution() {
        for (int i = 0; i < variables.Count; ++i)
            GD.Print($"v{i}: {variables[i].value}");
    }
    bool Satisfiable() {
        if (weightDict.Count == 0)
            return true;
        int min_weight = -1;
        int min_id = -1;
        foreach (KeyValuePair<int, int> kv in weightDict) {
            int id = kv.Key;
            int weight = kv.Value;
            if (min_weight > weight || min_id == -1) {
                min_id = id;
                min_weight = weight;
            }
        }
        if (min_weight == 0)
            return false;
        foreach (KeyValuePair<int, int> kv in clauses[min_id].variables) {
            int variable = kv.Key;
            for (int assignment = 0; assignment <= 1; ++assignment) {
                bool ok = true;
                variables[variable].value = assignment;
                foreach (int affected_clause in variables[variable].clauses)
                    clauses[affected_clause].Unlink(variable, assignment);
                foreach (int affected_clause in variables[variable].clauses) {
                    int new_weight = UpdateWeight(affected_clause);
                    if (new_weight == 0) {
                        ok = false;
                        break;
                    }
                }
                if (ok)
                    ok = Satisfiable();
                foreach (int affected_clause in variables[variable].clauses) {
                    clauses[affected_clause].Relink(variable);
                    UpdateWeight(affected_clause);
                }
                if (ok)
                    return true;
                variables[variable].value = -1;
            }
            break;
        }
        return false;
    }
}