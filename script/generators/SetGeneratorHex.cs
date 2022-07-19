using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorHex : SetGenerator {
    public override (WitnessGenerator, GeneratorFlags) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        GeneratorFlags flags = new GeneratorFlags();
        flags.Solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        if (tokens[1] == "1") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.HexGraph(3, "round", "left", "right"));
                generator.AddDecorator(new Decorators.PointDecorator(), 4);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.HexGraph(3, "round", "left", "right"));
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(4, 6), 2), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 2);
            } else {
                generator = new WitnessGenerator(Graph.HexGraph(4, "pyramid", "left", "right"));
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);

            }
            ApplyColorScheme(generator.Graph, "Intro");
        } else if (tokens[1] == "shuffle1") {
            int id = shuffledIndices[int.Parse(tokens[2]) - 1];
            if (id == 0) {
                generator = new WitnessGenerator(Graph.HexGraph(5, "round", "none", "none"));
                generator.Graph.NumWays = 2;
                SetCornerStart(generator.Graph, 91, new Vector(0, 1));
                SetCornerStart(generator.Graph, -89, new Vector(0, -1));
                SetCornerEnd(generator.Graph, 89, 90);
                SetCornerEnd(generator.Graph, -91, -90);
                generator.AddDecorator(new Decorators.PointDecorator(0), 2);
                generator.AddDecorator(new Decorators.PointDecorator(1), 2);
                generator.AddDecorator(new Decorators.PointDecorator(), 2);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
                flags.VertexComplexity = 0.7;
            } else if (id == 1) {
                generator = new WitnessGenerator(Graph.HexGraph(4, "diamond", "none", "none"));
                generator.Graph.Rotate(-30);
                SetCornerStart(generator.Graph, 180);
                SetCornerEnd(generator.Graph, 0, 0);
                generator.AddDecorator(new Decorators.StarDecorator(0), 4);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.PointDecorator(), 4);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
                SetCornerStart(generator.Graph, 135);
                SetCornerEnd(generator.Graph, -45, -30);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomHexTetris(new int[] { 3, 4 }, localRng, 0), false, false, 3), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomHexTetris(new int[] { 3, 4 }, localRng, 0), false, false, 3), 1);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 3);
            } else if (id == 3) {
                generator = new WitnessGenerator(Graph.HexGraph(5, "inverted-pyramid", "center", "center"));
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
                generator.AddDecorator(new Decorators.StarDecorator(2), 3);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            }
            ApplyColorScheme(generator.Graph, "Shuffle");
        } else if (tokens[1] == "select1") {
            flags.Solvable = tokens[2] == solvable1.ToString();
            generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
            SetCornerStart(generator.Graph, 135);
            SetCornerEnd(generator.Graph, -45, -30);
            generator.AddDecorator(new Decorators.SquareDecorator(0), 6);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 6);
            ApplyColorScheme(generator.Graph, "Intro");
        } else if (tokens[1] == "select2") {
            flags.Solvable = tokens[2] == solvable2.ToString();
            generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
            SetCornerStart(generator.Graph, 135);
            SetCornerEnd(generator.Graph, -45, -30);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 4);
            generator.AddDecorator(new Decorators.SquareDecorator(3), 2);
            generator.AddDecorator(new Decorators.SquareDecorator(4), 2);
            ApplyColorScheme(generator.Graph, "Intro");
            generator.PreTest = PreTests.VertexSquareColorTest;
        } else if (tokens[1] == "meta1") {
            generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
            SetCornerStart(generator.Graph, 135);
            SetCornerEnd(generator.Graph, -45, -30);
            generator.AddDecorator(new Decorators.StarDecorator(2), 2);
            generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
            generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
            generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
            ApplyColorScheme(generator.Graph, "Meta");
        } else if (tokens[1] == "6") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
                SetCornerStart(generator.Graph, 135);
                SetCornerEnd(generator.Graph, -45, -30);
                for (int _ = 0; _ < 5; ++_)
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.HexGraph(4, "rect", "none", "none"));
                SetCornerStart(generator.Graph, 135);
                SetCornerEnd(generator.Graph, -45, -30);
                for (int _ = 0; _ < 3; ++_)
                    generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 6), 2), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomHexTetris(new int[] { 2, 3 }, localRng, 0), true, false, 3), 1);
                generator.AddDecorator(new Decorators.TetrisDecorator(
                    RandomHexTetris(new int[] { 3, 4 }, localRng, 0), false, false, 2), 1);
            }
            ApplyColorScheme(generator.Graph, "InMaze");
        } else if (tokens[1] == "7") {
            int id = int.Parse(tokens[2]);
            if (id == 1) {
                generator = new WitnessGenerator(Graph.HexGraph(6, "rect_sym_ext", "none", "none"));
                generator.Graph.NumWays = 2;
                SetCornerStart(generator.Graph, 91, new Vector(0, 1));
                SetCornerStart(generator.Graph, 89, new Vector(0, 1), true);
                SetCornerEnd(generator.Graph, -89, -90);
                SetCornerEnd(generator.Graph, -91, -90);
                generator.AddDecorator(new Decorators.SquareDecorator(0), 6);
                generator.AddDecorator(new Decorators.SquareDecorator(1), 6);
                generator.AddDecorator(new Decorators.PointDecorator(), 4);
            } else if (id == 2) {
                generator = new WitnessGenerator(Graph.HexGraph(6, "rect_sym_ext", "none", "none"));
                generator.Graph.NumWays = 2;
                SetCornerStart(generator.Graph, 91, new Vector(0, 1));
                SetCornerStart(generator.Graph, 89, new Vector(0, 1), true);
                SetCornerEnd(generator.Graph, -89, -90);
                SetCornerEnd(generator.Graph, -91, -90);
                generator.AddDecorator(new Decorators.StarDecorator(0), 6);
                generator.AddDecorator(new Decorators.StarDecorator(1), 6);
                generator.AddDecorator(new Decorators.BrokenDecorator(), 4);
            }
            ApplyColorScheme(generator.Graph, "Pillar");
        } else {
            generator = new WitnessGenerator(Graph.RectangularGraph(2, 2));
        }
        return (generator, flags);
    }
}
