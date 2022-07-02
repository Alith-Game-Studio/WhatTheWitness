using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorMinesweeper : SetGenerator {

    Decorators.MinesweeperDecorator MinesweeperAutoColor(int count) {
        return new Decorators.MinesweeperDecorator(count, (count + 1) % 8);
    }
    public override (WitnessGenerator, bool, double) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        bool solvable = true;
        double hardness = 0.0;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(0, 8)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(0, 8)), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(MinesweeperAutoColor(1), 4);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(MinesweeperAutoColor(2), 4);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(MinesweeperAutoColor(3), 4);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(MinesweeperAutoColor(4), 4);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            }
        } else if (tokens[1] == "2") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(7, 2));
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 6)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 6)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 6)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 6)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 6)), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.PointDecorator(), 25);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 5)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(0, 5)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 5)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 8), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 8), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 8), 1);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                for (int i = 0; i < 8; ++i)
                    generator.AddDecorator(MinesweeperAutoColor(i), 1);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(0, 5)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(0, 5)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 5)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
                generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
                generator.AddDecorator(new Decorators.EliminatorDecorator(9), 1);
            }
        } else if (tokens[1] == "select1") {
            solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(MinesweeperAutoColor(localRng.Next(0, 5)), 1);
            generator.AddDecorator(MinesweeperAutoColor(localRng.Next(0, 5)), 1);
            generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
            generator.AddDecorator(MinesweeperAutoColor(localRng.Next(1, 8)), 1);
        }
        ApplyColorScheme(generator.Graph, "Minesweeper");
        return (generator, solvable, hardness);
    }
}
