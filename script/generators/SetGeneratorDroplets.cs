using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorDroplets : SetGenerator {
    public override (WitnessGenerator, GeneratorFlags) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        GeneratorFlags flags = new GeneratorFlags();
        flags.Solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 3));
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 3));
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.DropDecorator(0, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(180, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90 * localRng.Next(0, 4), 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            }
        } else if (tokens[1] == "2") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.DropDecorator(0, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(180, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 1);
                generator.AddDecorator(new Decorators.StarDecorator(3), 2);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.DropDecorator(0, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(180, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 1);
                generator.AddDecorator(new Decorators.PointDecorator(), 25);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.DropDecorator(0, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(90, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(180, 3), 1);
                generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 1);
                generator.AddDecorator(new Decorators.RingDecorator(3), 1);
                generator.AddDecorator(new Decorators.CircleDecorator(3), 1);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.DropDecorator(0, 3), 2);
                generator.AddDecorator(new Decorators.DropDecorator(90, 3), 2);
                generator.AddDecorator(new Decorators.DropDecorator(180, 3), 2);
                generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 2);
                generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 5));
                generator.AddDecorator(new Decorators.DropDecorator(0, 3), 2);
                generator.AddDecorator(new Decorators.DropDecorator(90, 3), 2);
                generator.AddDecorator(new Decorators.DropDecorator(180, 3), 2);
                generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 2);
                generator.AddDecorator(new Decorators.StarDecorator(3), 2);
            }
        } else if (tokens[1] == "select1") {
            flags.Solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.DropDecorator(0, 3), 1);
            generator.AddDecorator(new Decorators.DropDecorator(90, 3), 1);
            generator.AddDecorator(new Decorators.DropDecorator(180, 3), 1);
            generator.AddDecorator(new Decorators.DropDecorator(-90, 3), 1);
        }
        ApplyColorScheme(generator.Graph, "Droplet");
        return (generator, flags);
    }
}
