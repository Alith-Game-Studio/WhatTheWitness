using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class SetGeneratorMultipleChoices : SetGenerator {
    protected int[] solvable;
    protected int starFullDotProblemType;
    public int NumChoices { get; private set; }
    public SetGeneratorMultipleChoices(int numChoices) {
        NumChoices = numChoices;
    }
    public override void Init(Random globalRng) {
        int[] indices = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 };
        solvable = indices.Select(x => globalRng.Next(1, NumChoices + 1)).ToArray();
        shuffledIndices = indices.ToList();
        Shuffle(globalRng, shuffledIndices);
        shuffledIndices.Sort((x, y) => (x / 5).CompareTo(y / 5)); // group sort
        starFullDotProblemType = globalRng.Next(2);
    }

    public override (WitnessGenerator, GeneratorFlags) GetGenerator(string name, Random globalRng, Random localRng) {
        WitnessGenerator generator = null;
        GeneratorFlags flags = new GeneratorFlags();
        flags.Solvable = true;
        string[] tokens = name.Split('.')[0].Split('-');
        int setId = shuffledIndices[int.Parse(tokens[1].Substring(6)) - 1] + 1;
        flags.Solvable = tokens[2] == solvable[setId - 1].ToString();
        if (setId == 1) {
            generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
            for (int _ = 0; _ < 4; ++_)
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
        } else if (setId == 2) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.StarDecorator(0), 6);
            generator.AddDecorator(new Decorators.StarDecorator(1), 6);
        } else if (setId == 3) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.StarDecorator(2), 8);
        } else if (setId == 4) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(0), 6);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 6);
        } else if (setId == 5) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(1), 4);
            generator.AddDecorator(new Decorators.SquareDecorator(3), 2);
            generator.AddDecorator(new Decorators.SquareDecorator(4), 2);
            generator.PreTest = PreTests.VertexSquareColorTest;
        } else if (setId == 6) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.PointDecorator(), 25);
            if (starFullDotProblemType == 0) {
                generator.AddDecorator(new Decorators.StarDecorator(0), 2);
                generator.AddDecorator(new Decorators.StarDecorator(1), 2);
            } else {
                generator.AddDecorator(new Decorators.StarDecorator(2), 4);
            }
        } else if (setId == 7) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.PointDecorator(), 25);
            generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 4);
            generator.PreTest = PreTests.VertexSquareColorTest;
        } else if (setId == 8) {
            generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
            for (int _ = 0; _ < 5; ++_)
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
        } else if (setId == 9) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.PointDecorator(), 25);
            int size1 = localRng.Next(1, 4);
            int size2 = localRng.Next(3, 5);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomRectTetris(size1, localRng, FULL_DOT_RECT_POLYMINO_INDICES), size1 > 1, false, 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomRectTetris(size2, localRng, FULL_DOT_RECT_POLYMINO_INDICES), true, false, 2), 1);
        } else if (setId == 10) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(0), 6);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 6);
            generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
        } else if (setId == 11) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
            generator.AddDecorator(new Decorators.StarDecorator(0), 2);
            generator.AddDecorator(new Decorators.StarDecorator(1), 2);
        } else if (setId == 12) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            for (int _ = 0; _ < 3; ++_)
                generator.AddDecorator(new Decorators.TriangleDecorator(localRng.Next(1, 4), 2), 1);
            generator.AddDecorator(new Decorators.StarDecorator(2), 3);
        } else if (setId == 13) {
            generator = new WitnessGenerator(Graph.RectangularGraph(3, 3));
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 3, 4 }, localRng), false, false, 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                                    RandomRectTetris(new int[] { 2, 3 }, localRng), false, true, 5), 1);
            generator.MaxTries = 5; // too slow verification
        } else if (setId == 14) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(0), 2);
            generator.AddDecorator(new Decorators.SquareDecorator(1), 2);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomRectTetris(new int[] { 3, 4 }, localRng), true, false, 2), 1);
            generator.AddDecorator(new Decorators.TetrisDecorator(
                RandomRectTetris(new int[] { 3, 4 }, localRng), false, false, 2), 1);
            generator.PreTest = PreTests.VertexSquareColorTest;
        } else if (setId == 15) {
            generator = new WitnessGenerator(Graph.RectangularGraph(4, 4));
            generator.AddDecorator(new Decorators.SquareDecorator(1), 4);
            generator.AddDecorator(new Decorators.SquareDecorator(3), 2);
            generator.AddDecorator(new Decorators.SquareDecorator(4), 2);
            generator.AddDecorator(new Decorators.EliminatorDecorator(1), 1);
        }
        if (setId <= 5)
            ApplyColorScheme(generator.Graph, "Intro");
        else if (setId <= 10)
            ApplyColorScheme(generator.Graph, "Normal");
        else if (setId <= 15)
            ApplyColorScheme(generator.Graph, "Hard");
        flags.ForceRectBackTrace = true;
        return (generator, flags);
    }
}
