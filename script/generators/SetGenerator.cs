using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;

public abstract class SetGenerator {
    protected int solvable1;
    protected int solvable2;
    protected List<int> shuffledIndices;
    public static int[][][] POLYMINO_INDICES = new int[][][]{
        new int[][] {new int[]{ } },
        new int[][] {new int[]{0} },
        new int[][] {new int[]{0, 1} },
        new int[][] {new int[]{0, 1, 2} ,new int[] { 0, 1, 10 } },
        new int[][] { new int[] { 0, 1, 2, 3 }, new int[] { 0, 1, 2, 10 }, new int[] { 0, 1, 2, 11 }, new int[] { 0, 1, 2, 12 },
            new int[]{0, 1, 11, 12 }, new int[]{1, 2, 10, 11 }, new int[]{0, 1, 10, 11 } },
        new int[][] {new int[] {0, 1, 2, 3, 4}, new int[] {0, 1, 2, 3, 10}, new int[] {0, 1, 2, 3, 13}, new int[] {0, 1, 11, 12, 21},
        new int[] {1, 2, 10, 11, 21},new int[]{0, 1, 10, 11, 20 }, new int[]{0, 1, 10, 11, 21 }, new int[]{ 0, 1, 2, 12, 13}, new int[]{0, 1, 11, 12, 13 },
        },
    };
    public static int[] RectangularRotate(int[] rectPolyminoIndices) {
        List<int> result = new List<int>();
        int sizeX = 1, sizeY = 1;
        foreach (int index in rectPolyminoIndices) {
            int x = index / 10, y = index % 10;
            sizeX = Math.Max(sizeX, x + 1);
            sizeY = Math.Max(sizeY, y + 1);
        }
        foreach (int index in rectPolyminoIndices) {
            int x = index / 10, y = index % 10;
            result.Add(y * 10 + sizeX - x - 1);
        }
        return result.ToArray();
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
    public static int[] RandomTetris(int size, int nCols, Random rng) {
        int[][] choices = POLYMINO_INDICES[size];
        int[] choice = choices[rng.Next(choices.Length)];
        int rotations = rng.Next(0, 4);
        for (int i = 0; i < rotations; ++i)
            choice = RectangularRotate(choice);
        return choice.Select(x => x / 10 * nCols + x % 10).ToArray();
    }
    public static int[] RandomTetris(int[] sizes, int nCols, Random rng) {
        int size = sizes[rng.Next(sizes.Length)];
        return RandomTetris(size, nCols, rng);
    }
    public abstract (WitnessGenerator, bool) GetGenerator(string name, Random globalRng, Random localRng);

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
        }
    }
}
