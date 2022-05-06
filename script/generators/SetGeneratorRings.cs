using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorRings : SetGenerator {
    public override (WitnessGenerator, bool) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        bool solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(1, 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(2, 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(3, 2), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.CircleDecorator(0), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(1, 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(3, 2), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.StarDecorator(0), 2);
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.PointDecorator(), 2);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
            }
        } else if (tokens[1] == "2") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 1);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 1);
                for (int _ = 0; _ < 1; ++_)
                    generator.AddDecorator(new Decorators.TetrisDecorator(
                                            RandomTetris(new int[] { 2, 3 }, 3, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.RingDecorator(1), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.StarDecorator(0), 2);
                generator.AddDecorator(new Decorators.StarDecorator(2), 2);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(new int[] { 2, 3 }, 4, localRng), true, false, 0), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(new int[] { 3, 4 }, 4, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.CircleDecorator(2), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5, "xy"));
                generator.AddDecorator(new Decorators.PointDecorator(), 2);
                generator.AddDecorator(new Decorators.TriangleDecorator(1), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(3), 1);
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 5);
            }
        } else if (tokens[1] == "3") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(6, 2));
                generator.AddDecorator(new Decorators.StarDecorator(0), 1);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(2, 2, localRng), true, false, 0), 1);
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.CircleDecorator(0), 2);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 0), 1);
                generator.AddDecorator(new Decorators.StarDecorator(0), 1);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(2, 4, localRng), false, false, 0), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(2, 4, localRng), true, false, 0), 1);
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 4));
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 0), 1);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 1);
                generator.AddDecorator(new Decorators.StarDecorator(0), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(2, 4, localRng), true, false, 0), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                                        RandomTetris(new int[] { 3, 4 }, 4, localRng), true, false, 0), 1);
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.CircleDecorator(0), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
            }

        } else if (tokens[1] == "select1") {
            solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.TriangleDecorator(1, 2), 1);
            generator.AddDecorator(new Decorators.TriangleDecorator(2, 2), 1);
            generator.AddDecorator(new Decorators.TriangleDecorator(3, 2), 1);
            generator.AddDecorator(new Decorators.RingDecorator(0), 1);
            generator.AddDecorator(new Decorators.CircleDecorator(0), 1);
        }
        ApplyColorScheme(generator.Graph, "Ring");
        return (generator, solvable);
    }
}
