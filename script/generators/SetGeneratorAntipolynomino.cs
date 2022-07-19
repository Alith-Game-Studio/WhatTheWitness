using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorAntipolynomino : SetGenerator {
    public static int[][][] ANTI_RECT_POLYMINO_INDICES = new int[][][]{
        new int[][] {},
        new int[][] {},
        new int[][] {new int[]{0, 1}, new int[] { 0, 11 }, new int[] { 0, 2 } },
        new int[][] {new int[]{0, 1, 2}, new int[] { 0, 1, 10 }, new int[] { 0, 1, 12 }, new int[] { 0, 11, 12 }, new int[] { 0, 11, 2 }, new int[] { 0, 10, 2 }, new int[] { 0, 10, 12 } },
        new int[][] { new int[] { 0, 1, 2, 3 }, new int[] { 0, 1, 2, 10 }, new int[] { 0, 1, 2, 11 }, new int[] { 0, 1, 2, 12 },
            new int[]{0, 1, 11, 12 }, new int[]{1, 2, 10, 11 }, new int[]{0, 1, 10, 11 }, new int[]{0, 10, 2, 20 }},
        new int[][] {new int[] {0, 1, 2, 3, 4}, new int[] {0, 1, 2, 3, 10}, new int[] {0, 1, 2, 3, 13}, new int[] {0, 1, 11, 12, 21},
        new int[] {1, 2, 10, 11, 21},new int[]{0, 1, 10, 11, 20 }, new int[]{0, 1, 10, 11, 21 }, new int[]{ 0, 1, 2, 12, 13}, new int[]{0, 1, 11, 12, 13 },
        },
    };
    public override (WitnessGenerator, GeneratorFlags) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        GeneratorFlags flags = new GeneratorFlags();
        flags.Solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 3));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 3));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.PointDecorator(-1, 1), 3);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(5, 3));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), true, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(4, localRng), true, 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
                generator.AddDecorator(new Decorators.PointDecorator(-1, 1), 3);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(4, localRng), true, 3), 1);
                generator.AddDecorator(new Decorators.StarDecorator(3), 3);
                generator.AddDecorator(new Decorators.PointDecorator(-1, 1), 2);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), true, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(4, localRng), true, 3), 1);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
                generator.AddDecorator(new Decorators.PointDecorator(-1, 1), 2);
            }
        } else if (tokens[1] == "2") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 3));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng, ANTI_RECT_POLYMINO_INDICES), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng, ANTI_RECT_POLYMINO_INDICES), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng, ANTI_RECT_POLYMINO_INDICES), false, 3), 1);
                generator.AddDecorator(new Decorators.PointDecorator(-1, 1), 3);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), true, 3), 1);
                generator.AddDecorator(new Decorators.PointDecorator(), 25);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng, ANTI_RECT_POLYMINO_INDICES), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng, ANTI_RECT_POLYMINO_INDICES), true, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng, ANTI_RECT_POLYMINO_INDICES), false, 4), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(4, localRng, ANTI_RECT_POLYMINO_INDICES), true, 4), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
                generator.AddDecorator(new Decorators.PointDecorator(-1, 1), 2);
                generator.AddDecorator(new Decorators.StarDecorator(3), 1);
                generator.AddDecorator(new Decorators.StarDecorator(4), 1);
            } else if (id == 4) {
                generator = new WitnessGenerator(Graph.HexGraph(5, "round", "none", "none"));
                SetCornerStart(generator.Graph, 91, new Vector(0, 1));
                SetCornerEnd(generator.Graph, -89, -90);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomHexTetris(2, localRng, 0), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomHexTetris(2, localRng, 0), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomHexTetris(3, localRng, 0), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomHexTetris(3, localRng, 0), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomHexTetris(4, localRng, 0), false, 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 5);
            } else {
                generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(2, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(3, localRng), false, 3), 1);
                generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                    RandomRectTetris(4, localRng), true, 3), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomRectTetris(4, localRng), true, false, 2), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
            }
        } else if (tokens[1] == "select1") {
            flags.Solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                RandomRectTetris(2, localRng), false, 3), 1);
            generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                RandomRectTetris(3, localRng), false, 3), 1);
            generator.AddDecorator(new Decorators.AntiTetrisDecorator(
                RandomRectTetris(4, localRng), false, 3), 1);
            generator.AddDecorator(new Decorators.StarDecorator(3), 1);
        }
        if (generator.Graph.RectangularGraphVertices != null)
            flags.ForceRectBackTrace = true; // prevent easy solutions
        ApplyColorScheme(generator.Graph, "Antipolynomino");
        return (generator, flags);
    }
}
