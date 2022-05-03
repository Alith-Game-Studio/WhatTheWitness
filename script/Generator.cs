using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

public class Generator : Node
{

    static int solvable1;
    static int solvable2;
    static List<int> shuffledIndices;
    static Dictionary<string, Graph> generatedPanels = new Dictionary<string, Graph>();
    public static int[][][] POLYDOMINO_INDICES = new int[][][]{
        new int[][] {new int[]{ } },
        new int[][] {new int[]{0} },
        new int[][] {new int[]{0, 1} },
        new int[][] {new int[]{0, 1, 2} ,new int[] { 0, 1, 10 } },
        new int[][] { new int[] { 0, 1, 2, 3 }, new int[] { 0, 1, 2, 10 }, new int[] { 0, 1, 2, 11 }, new int[] { 0, 1, 2, 12 },
            new int[]{0, 1, 11, 12 }, new int[]{1, 2, 10, 11 }, new int[]{0, 1, 10, 11 } },
    };
    public static int StringHash(string str) {
        uint value = 0;
        foreach (char c in str) {
            value = value * 31 + c;
        }
        return (int)value;
    }
    public static string GeneratePanel(string name, int seed) {
        GD.Print("Generating " + name);
        string storeKey = name + seed;
        if (generatedPanels.ContainsKey(storeKey))
            return generatedPanels[storeKey].ToXML();
        Random globalRng = new Random(seed);
        Random localRng = new Random(StringHash(name) + seed);

        solvable1 = globalRng.Next(1, 4);
        solvable2 = globalRng.Next(1, 4);
        shuffledIndices =  new List<int>() { 0, 1, 2, 3 };
        Shuffle(globalRng, shuffledIndices);
        while (true) {
            (WitnessGenerator generator, bool solvable) = GetGenerator(name, globalRng, localRng);
            int[] multiSolveVertices = name.Contains("meta1") ? new int[] { 0, 80 } : null;
            Graph graph = generator.Sample(localRng, solvable, false, multiSolveVertices, 30);
            if (graph != null) {
                generatedPanels[storeKey] = graph;
                GD.Print("Generated " + name);
                return graph.ToXML();
            }
        }
    }
    public static void Shuffle<T>(Random rng, IList<T> list) {
        int n = list.Count;
        while (n > 1) {
            n--;
            int k = rng.Next(n + 1);
            T value = list[k];
            list[k] = list[n];
            list[n] = value;
        }
    }
    public static int[] RandomTetris(int size, int nCols, Random rng) {
        int[][] choices = POLYDOMINO_INDICES[size];
        int[] choice = choices[rng.Next(choices.Length)];
        return choice.Select(x => x / 10 * nCols + x % 10).ToArray();
    }
    public static int[] RandomTetris(int[] sizes, int nCols, Random rng) {
        int size = sizes[rng.Next(sizes.Length)];
        return RandomTetris(size, nCols, rng);
    }
    public static (WitnessGenerator, bool) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        bool solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        string setName = tokens[0].Substring(tokens[0].LastIndexOf(']') + 1);
        if (setName == "Normal") {
            if (tokens[1] == "1") {
                int id = int.Parse(tokens[2]);
                if (id == 1) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    generator.AddDecorator(new Decorators.SquareDecorator(0), 4);
                    generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                } else if (id == 2) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    generator.AddDecorator(new Decorators.PointDecorator(), 25);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                } else {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                    generator.AddDecorator(new Decorators.PointDecorator(), 2);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 3);

                }
            } else if (tokens[1] == "shuffle1") {
                int id = shuffledIndices[int.Parse(tokens[2]) - 1];
                if (id == 0) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(6, 6, "xy"));
                    generator.AddDecorator(new Decorators.PointDecorator(0), 2);
                    generator.AddDecorator(new Decorators.PointDecorator(1), 2);
                    generator.AddDecorator(new Decorators.PointDecorator(), 2);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 5);
                } else if (id == 1) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    generator.AddDecorator(new Decorators.StarDecorator(0), 4);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                    generator.AddDecorator(new Decorators.PointDecorator(), 25);
                } else if (id == 2) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                    generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                    generator.AddDecorator(new Decorators.TetrisDecorator(
                        RandomTetris(new int[] { 3, 4 }, 4, localRng), false, false, 2), 1);
                    generator.AddDecorator(new Decorators.TetrisDecorator(
                        RandomTetris(new int[] { 3, 4 }, 4, localRng), true, false, 2), 1);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
                } else if (id == 3) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 2);
                    generator.AddDecorator(new Decorators.StarDecorator(2), 3);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                }
            } else if (tokens[1] == "select1") {
                solvable = tokens[2] == solvable1.ToString();
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 4);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(2), 2);
            } else if (tokens[1] == "select2") {
                solvable = tokens[2] == solvable2.ToString();
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.StarDecorator(0), 6);
                generator.AddDecorator(new Decorators.StarDecorator(1), 6);
            } else if (tokens[1] == "meta1") {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.StarDecorator(2), 2);
                generator.AddDecorator(new Decorators.TriangleDecorator(3, 2), 3);
            } else if (tokens[1] == "6") {
                int id = int.Parse(tokens[2]);
                if (id == 1) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    generator.AddDecorator(new Decorators.PointDecorator(), 25);
                    for (int _ = 0; _ < 3; ++_)
                        generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                } else if (id == 2) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                    for (int _ = 0; _ < 3; ++_)
                        generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                    generator.AddDecorator(new Decorators.TetrisDecorator(
                        RandomTetris(new int[] { 3, 4 }, 4, localRng), true, false, 2), 1);
                    generator.AddDecorator(new Decorators.TetrisDecorator(
                        RandomTetris(new int[] { 3, 4 }, 4, localRng), true, false, 2), 1);
                }
            } else if (tokens[1] == "7") {
                int id = int.Parse(tokens[2]);
                if (id == 1) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(7, 6, "x"));
                    generator.AddDecorator(new Decorators.SquareDecorator(0), 6);
                    generator.AddDecorator(new Decorators.SquareDecorator(1), 6);
                    generator.AddDecorator(new Decorators.PointDecorator(), 4);
                } else if (id == 2) {
                    generator = new WitnessGenerator(Graph.RectangularGraph(7, 6, "x"));
                    generator.AddDecorator(new Decorators.StarDecorator(0), 6);
                    generator.AddDecorator(new Decorators.StarDecorator(1), 6);
                    generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                }
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(2, 2));
            }
        } else if (setName == "Misc") {
            if (tokens[1] == "1") {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 4);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 4);
                generator.AddDecorator(new Decorators.StarDecorator(0), 3);
                generator.AddDecorator(new Decorators.StarDecorator(1), 3);
            } else if (tokens[1] == "2") {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5, "xy"));
                generator.AddDecorator(new Decorators.PointDecorator(), 36);
                for (int _ = 0; _ < 3; ++_)
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            } else if (tokens[1] == "3") {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(new Decorators.StarDecorator(0), 6);
                for (int _ = 0; _ < 3; ++_)
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(new int[] { 3, 4 }, 5, localRng), true, false, 2), 1);

            } else if (tokens[1] == "select1") {
                solvable = tokens[2] == solvable1.ToString();
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                for (int _ = 0; _ < 6; ++_)
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            }
        }

                return (generator, solvable);
    }
}
