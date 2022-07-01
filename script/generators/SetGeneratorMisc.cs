using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorMisc : SetGenerator {
    public override (WitnessGenerator, bool, double) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        bool solvable = true;
        double hardness = 0.0;
        string[] tokens = name.Split('.')[0].Split('-');
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
                                        RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);

        } else if (tokens[1] == "4") {
            generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
            SetCornerStart(generator.Graph, 135);
            SetCornerEnd(generator.Graph, -45, -30);
            for (int _ = 0; _ < 3; ++_)
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
            SetHexFullPoint(generator.Graph);
            ApplyColorScheme(generator.Graph, "InMaze");
        } else if (tokens[1] == "5") {
            generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
            SetCornerStart(generator.Graph, 135);
            SetCornerEnd(generator.Graph, -45, -30);
            for (int _ = 0; _ < 3; ++_)
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomHexTetris(new int[] { 3, 4 }, localRng, 0), true, false, 3), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomHexTetris(new int[] { 3, 4 }, localRng, 0), true, false, 3), 1);
            ApplyColorScheme(generator.Graph, "InMaze");
        } else if (tokens[1] == "6") {
            generator = new WitnessGenerator(Graph.HexGraph(5, "rect", "none", "none"));
            SetCornerStart(generator.Graph, 135);
            SetCornerEnd(generator.Graph, -45, -30);
            for (int _ = 0; _ < 3; ++_)
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomHexTetris(new int[] { 2, 3 }, localRng, 0), true, false, 3), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomHexTetris(new int[] { 3, 4 }, localRng, 0), true, false, 3), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomHexTetris(new int[] { 3, 4 }, localRng, 0), true, false, 3), 1);
            ApplyColorScheme(generator.Graph, "InMaze");
        } else if (tokens[1] == "7") {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.StarDecorator(6), 4);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 2, 3 }, localRng), true, true, 6), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 2, 3 }, localRng), true, true, 6), 1);
            generator.MaxTries = 5; // too slow verification
        } else if (tokens[1] == "8") {
            generator = new WitnessGenerator(Graph.RectangularGraph(6, 6));
            generator.AddDecorator(new Decorators.DropDecorator(0, 3), 2);
            generator.AddDecorator(new Decorators.DropDecorator(90, 3), 2);
            generator.AddDecorator(new Decorators.DropDecorator(180, 3), 2);
            generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 2);
            generator.AddDecorator(new Decorators.StarDecorator(3), 4);
            ApplyColorScheme(generator.Graph, "Droplet");
        } else if (tokens[1] == "select1") {
            solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            for (int _ = 0; _ < 6; ++_)
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
        }
        return (generator, solvable, hardness);
    }
}
