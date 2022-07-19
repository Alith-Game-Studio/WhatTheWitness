using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorEliminators : SetGenerator {
    public override (WitnessGenerator, GeneratorFlags) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        GeneratorFlags flags = new GeneratorFlags();
        flags.Solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 4);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 4);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(2), 2);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.PointDecorator(), 2);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);

            }
            ApplyColorScheme(generator.Graph, "Intro");
        } else if (tokens[1] == "shuffle1") {
            int id = shuffledIndices[int.Parse(tokens[2]) - 1];
            if (id == 0) {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5, "xy"));
                generator.AddDecorator(new Decorators.PointDecorator(0), 2);
                generator.AddDecorator(new Decorators.PointDecorator(1), 2);
                generator.AddDecorator(new Decorators.PointDecorator(), 2);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 5);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            } else if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(new Decorators.StarDecorator(0), 6);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                generator.AddDecorator(new Decorators.PointDecorator(), 36);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomRectTetris(new int[] { 3, 4 }, localRng), false, false, 2), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 2);
                generator.AddDecorator(new Decorators.StarDecorator(2), 3);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            }
            ApplyColorScheme(generator.Graph, "Shuffle");
        } else if (tokens[1] == "select1") {
            flags.Solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(0), 6);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 6);
            generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            ApplyColorScheme(generator.Graph, "Intro");
        } else if (tokens[1] == "select2") {
            flags.Solvable = tokens[2] == solvable2.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(1), 4);
            generator.AddDecorator(new Decorators.SquareDecorator(3), 2);
            generator.AddDecorator(new Decorators.SquareDecorator(4), 2);
            generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            ApplyColorScheme(generator.Graph, "Intro");
        } else if (tokens[1] == "meta1") {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.StarDecorator(2), 2);
            generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            ApplyColorScheme(generator.Graph, "Meta");
        } else if (tokens[1] == "6") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.PointDecorator(), 25);
                for (int _ = 0; _ < 3; ++_)
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                for (int _ = 0; _ < 3; ++_)
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            }
            ApplyColorScheme(generator.Graph, "InMaze");
        } else if (tokens[1] == "7") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(7, 6, "x"));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 6);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 5);
                generator.AddDecorator(new Decorators.PointDecorator(), 4);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(new Decorators.PointDecorator(), 36);
                for (int _ = 0; _ < 4; ++_)
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            }
            ApplyColorScheme(generator.Graph, "Pillar");
        } else {
            generator = new WitnessGenerator(Graph.RectangularGraph(2, 2));
        }
        return (generator, flags);
    }
}
