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
    public static int[][][] POLYDOMINO_INDICES = new int[][][]{
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
        int[][] choices = POLYDOMINO_INDICES[size];
        int[] choice = choices[rng.Next(choices.Length)];
        return choice.Select(x => x / 10 * nCols + x % 10).ToArray();
    }
    public static int[] RandomTetris(int[] sizes, int nCols, Random rng) {
        int size = sizes[rng.Next(sizes.Length)];
        return RandomTetris(size, nCols, rng);
    }
    public abstract (WitnessGenerator, bool) GetGenerator(string name, Random globalRng, Random localRng);
}
