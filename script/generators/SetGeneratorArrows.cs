using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorArrows : SetGenerator {
    public override (WitnessGenerator, GeneratorFlags) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        GeneratorFlags flags = new GeneratorFlags();
        flags.Solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.ArrowDecorator(45 + 90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 + 90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 1);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.ArrowDecorator(45 + 90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 + 90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 + 90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            }
        } else if (tokens[1] == "2") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.PointDecorator(), 25);
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(90 * localRng.Next(0, 4), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 3), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomRectTetris(new int[] { 3, 4 }, localRng), false, false, 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5, "xy"));
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 5);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.HexGraph(5, "round", "none", "none"));
                SetCornerStart(generator.Graph, 91, new Vector(0, 1));
                SetCornerEnd(generator.Graph, -89, -90);
                generator.AddDecorator(new Decorators.ArrowDecorator(60 * localRng.Next(0, 8) - 30, localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(60 * localRng.Next(0, 8) - 30, localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(60 * localRng.Next(0, 8) - 30, localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(60 * localRng.Next(0, 8) - 30, localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(60 * localRng.Next(0, 8) - 30, localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            }
        } else if (tokens[1] == "select1") {
            flags.Solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
            generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
            generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
            generator.AddDecorator(new Decorators.ArrowDecorator(45 * localRng.Next(0, 8), localRng.Next(1, 4), 3), 1);
        }
        ApplyColorScheme(generator.Graph, "Arrow");
        return (generator, flags);
    }
}
