using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

public abstract class SetGenerator {
    protected int solvable1;
    protected int solvable2;
    protected List<int> shuffledIndices;
    public static int[][][] RECT_POLYMINO_INDICES = new int[][][]{
        new int[][] {},
        new int[][] {new int[]{0} },
        new int[][] {new int[]{0, 1} },
        new int[][] {new int[]{0, 1, 2} ,new int[] { 0, 1, 10 } },
        new int[][] { new int[] { 0, 1, 2, 3 }, new int[] { 0, 1, 2, 10 }, new int[] { 0, 1, 2, 11 }, new int[] { 0, 1, 2, 12 },
            new int[]{0, 1, 11, 12 }, new int[]{1, 2, 10, 11 }, new int[]{0, 1, 10, 11 } },
        new int[][] {new int[] {0, 1, 2, 3, 4}, new int[] {0, 1, 2, 3, 10}, new int[] {0, 1, 2, 3, 13}, new int[] {0, 1, 11, 12, 21},
        new int[] {1, 2, 10, 11, 21},new int[]{0, 1, 10, 11, 20 }, new int[]{0, 1, 10, 11, 21 }, new int[]{ 0, 1, 2, 12, 13}, new int[]{0, 1, 11, 12, 13 },
        },
    };
    public static int[][][] HEX_POLYMINO_INDICES = new int[][][] {
        new int[][] {},
        new int[][] {new int[]{0} },
        new int[][] {new int[]{0, 1} },
        new int[][] {new int[]{0, 1, 2} ,new int[] { 0, 1, 10 } ,new int[] { 0, 1, 11 } },
        new int[][] {new int[]{0, 1, 2, 3} ,new int[] { 0, 1, 2, 12 } ,new int[] { 0, 1, 11, 21 }, new int[]{0, 1, 10, 20 }, new int[]{0, 1, 2, 10 },
            new int[] { 1, 11, 12, 20 }, new int[] { 0, 1, 11, 20 },new int[]{0, 1, 10, 11 }, new int[]{0, 10, 11, 21 }, new int[]{0, 1, 11, 12 } },
    };
    public static IEnumerable<Vector[]> TetrisRotate(IEnumerable<Vector[]> shapes, double degree) {
        double angle = degree / 180 * Math.PI;
        double cosAngle = Math.Cos(angle);
        double sinAngle = Math.Sin(angle);
        return shapes.Select(shape => shape.Select(vec =>
            new Vector(cosAngle * vec.X - sinAngle * vec.Y, sinAngle * vec.X + cosAngle * vec.Y)).ToArray());
    }
    public void Init(Random globalRng) {
        solvable1 = globalRng.Next(1, 4);
        solvable2 = globalRng.Next(1, 4);
        shuffledIndices = new List<int>() { 0, 1, 2, 3 };
        Shuffle(globalRng, shuffledIndices);
    }
    public static void Shuffle<T>(Random rng, IList<T> list) {
        int n = list.Count;
        while (n > 1) {
            n--;
            int k = rng.Next(n + 1);
            T value = list[k];
            list[k] = list[n];
            list[n] = value;
        }
    }
    public static Vector[][] RandomRectTetris(int size, Random rng, int[][][] template=null) {
        int[][] choices = (template ?? RECT_POLYMINO_INDICES)[size];
        int[] choice = choices[rng.Next(choices.Length)];
        IEnumerable<Vector[]> shapes = choice.Select(center => new Vector[] {
            new Vector(center / 10, center % 10),
            new Vector(center / 10 + 1, center % 10),
            new Vector(center / 10 + 1, center % 10 + 1),
            new Vector(center / 10, center % 10 + 1),
        });
        int rotations = rng.Next(0, 4);
        for (int i = 0; i < rotations; ++i)
            shapes = TetrisRotate(shapes, 90);
        return shapes.ToArray();
    }
    public static Vector[][] RandomHexTetris(int size, Random rng, double degree=0, double scale=0.7) {
        int[][] choices = HEX_POLYMINO_INDICES[size];
        int[] choice = choices[rng.Next(choices.Length)];
        double h = Math.Sqrt(3) / 2, w = 0.5;
        IEnumerable<Vector[]> shapes = choice.Select(center => {
            double x = (center / 10 + center % 10 * 0.5) * Math.Sqrt(3);
            double y = center % 10 * 1.5;
            return new Vector[] {
                new Vector(x, y - 2 * w) * scale,
                new Vector(x + h, y - w) * scale,
                new Vector(x + h, y + w) * scale,
                new Vector(x, y + 2 * w) * scale,
                new Vector(x - h, y + w) * scale,
                new Vector(x - h, y - w) * scale,
            };
        });
        int rotations = rng.Next(0, 6);
        if (degree != 0)
            shapes = TetrisRotate(shapes, degree);
        for (int i = 0; i < rotations; ++i)
            shapes = TetrisRotate(shapes, 60);
        return shapes.ToArray();
    }
    public static Vector[][] RandomRectTetris(int[] sizes, Random rng) {
        int size = sizes[rng.Next(sizes.Length)];
        return RandomRectTetris(size, rng);
    }
    public static Vector[][] RandomHexTetris(int[] sizes, Random rng, double degree = 0, double scale = 0.7) {
        int size = sizes[rng.Next(sizes.Length)];
        return RandomHexTetris(size, rng, degree, scale);
    }

    public static Vertex GetCornerVertex(Graph graph, double degree) {
        double angle = degree / 180 * Math.PI;
        Vector dir = new Vector(Math.Cos(angle), Math.Sin(angle));
        Vertex best = graph.Vertices[0];
        foreach (Vertex vertex in graph.Vertices) {
            if (vertex.LinkedEdge == null && vertex.LinkedFacet == null) {
                if ((vertex.Pos ^ dir) > (best.Pos ^ dir)) best = vertex;
            }
        }
        return best;
    }
    protected static void SetCornerStart(Graph graph, double degree, Vector symmetryNormal = null, bool flip = false) {
        Vertex best = GetCornerVertex(graph, degree);
        best.IsPuzzleStart = true;
        best.StartSymmetryNormal = symmetryNormal;
        best.StartSymmetryFlip = flip;
    }
    protected static void SetCornerEnd(Graph graph, double degree, double endAngle) {
        double angle = degree / 180 * Math.PI;
        Vector dir = new Vector(Math.Cos(angle), Math.Sin(angle));
        Vertex best = graph.Vertices[0];
        foreach (Vertex vertex in graph.Vertices) {
            if (vertex.LinkedEdge == null && vertex.LinkedFacet == null) {
                if ((vertex.Pos ^ dir) > (best.Pos ^ dir)) best = vertex;
            }
        }
        best.IsPuzzleEnd = true;
        best.EndAngle = endAngle;
    }
    protected static void SetHexFullPoint(Graph graph) {
        foreach (Vertex vertex in graph.Vertices) {
            if (vertex.LinkedEdge == null && vertex.LinkedFacet == null && vertex.ConnectedEdges.Count >= 3)
                vertex.Decorator = new Decorators.PointDecorator();
        }
    }
    public abstract (WitnessGenerator, bool, double) GetGenerator(string name, Random globalRng, Random localRng);

    public void ApplyColorScheme(Graph graph, string scheme) {
        if (scheme == "Intro") {
            graph.BackgroundColor = "#00C8AF";
            graph.ForegroundColor = "#234B5A";
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "#eeeeee" };
            graph.ColorMap = new List<string> { "Black", "White", "Gold", "#98cd88", "#9639e5" };

        } else if (scheme == "Shuffle") {
            graph.BackgroundColor = "#00b06f";
            graph.ForegroundColor = "#496853";
            graph.ColorMap = new List<string> { "Black", "White", "Gold", "#bc48b8", "#49ddb0" };
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "#ffeecc" };
        } else if (scheme == "Meta") {
            graph.BackgroundColor = "#001f5c";
            graph.ForegroundColor = "#6387ce";
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "#eeeeee" };
        } else if (scheme == "InMaze") {
            graph.BackgroundColor = "Black";
            graph.ForegroundColor = "#a88f23";
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "#ffc600" };
        } else if (scheme == "Pillar") {
            graph.BackgroundColor = "#703000";
            graph.ForegroundColor = "#d29300";
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "#F2C454" };
            else if (graph.NumWays == 2)
                    graph.LineColorMap = new List<string>() { "#F2C454", "#F2C454" };
        } else if (scheme == "Ring") {
            graph.BackgroundColor = "#400040";
            graph.ForegroundColor = "Purple";
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "Violet" };
            if (graph.NumWays == 2)
                graph.LineColorMap = new List<string>() { "Violet", "Aqua" };
            graph.ColorMap = new List<string>() { "Violet", "White", "Yellow", "Aqua" };
        } else if (scheme == "Arrow") {
            graph.BackgroundColor = "DarkGray";
            graph.ForegroundColor = "#645a3c";
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "BlueViolet" };
            if (graph.NumWays == 2)
                graph.LineColorMap = new List<string>() { "BlueViolet", "BlueViolet" };
            graph.ColorMap = new List<string>() { "Black", "White", "Yellow", "BlueViolet" };
        } else if (scheme == "Antipolynomino") {
            graph.BackgroundColor = "Gray";
            graph.ForegroundColor = "DarkRed";
            if (graph.NumWays == 1)
                graph.LineColorMap = new List<string>() { "Yellow" };
            if (graph.NumWays == 2)
                graph.LineColorMap = new List<string>() { "Yellow", "Aqua" };
            graph.ColorMap = new List<string>() { "Black", "White", "Yellow", "#C00000", "#404040" };
        }
    }
}
