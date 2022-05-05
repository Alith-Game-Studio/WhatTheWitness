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
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5, "xy"));
                generator.AddDecorator(new Decorators.PointDecorator(), 2);
                generator.AddDecorator(new Decorators.TriangleDecorator(1), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(3), 1);
                generator.AddDecorator(new Decorators.RingDecorator(0), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 5);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.StarDecorator(0), 4);
                for (int _ = 0; _ < 2; ++_)
                    generator.AddDecorator(new Decorators.TetrisDecorator(
                                            RandomTetris(new int[] { 3, 4 }, 4, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.RingDecorator(2), 1);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.StarDecorator(0), 4);
                for (int _ = 0; _ < 2; ++_)
                    generator.AddDecorator(new Decorators.TetrisDecorator(
                                            RandomTetris(new int[] { 3, 4 }, 4, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.RingDecorator(2), 1);
                generator.AddDecorator(new Decorators.CircleDecorator(2), 1);
            }
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
        return (generator, solvable);
    }
}
