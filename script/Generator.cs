using Godot;
using System;
using System.Collections.Generic;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

public class Generator : Node
{
    static Dictionary<string, Graph> generatedPanels = new Dictionary<string, Graph>();
    public static int StringHash(string str) {
        uint value = 0;
        foreach (char c in str) {
            value = value * 31 + c;
        }
        return (int)value;
    }
    public static string GeneratePanel(string name, int seed) {
        GD.Print(name);
        string storeKey = name + seed;
        if (generatedPanels.ContainsKey(storeKey))
            return generatedPanels[storeKey].ToXML();
        (WitnessGenerator generator, bool solvable) = GetGenerator(name);
        Random rng = new Random(StringHash(name) + seed);
        Graph graph = generator.Sample(rng, solvable, false);
        generatedPanels[storeKey] = graph;
        return graph.ToXML();
    }
    public static (WitnessGenerator, bool) GetGenerator(string name) {
        WitnessGenerator generator = null;
        bool solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            if (tokens[2] == "1") {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.TriangleDecorator(2, 2), 1);
            } else if (tokens[2] == "2") {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 3);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 3);
                generator.AddDecorator(new Decorators.TriangleDecorator(2, 2), 2);
            } else if (tokens[2] == "3") {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 3);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 3);
                generator.AddDecorator(new Decorators.TriangleDecorator(1, 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(2, 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(3, 2), 1);
            }
        } else if (tokens[1] == "2") {
            solvable = tokens[2] == "2";
            generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
            generator.AddDecorator(new Decorators.TriangleDecorator(1, 2), 1);
            generator.AddDecorator(new Decorators.TriangleDecorator(2, 2), 2);
            generator.AddDecorator(new Decorators.TriangleDecorator(3, 2), 1);
        }
        return (generator, solvable);
    }
}
