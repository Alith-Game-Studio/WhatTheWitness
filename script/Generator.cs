using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

public class Generator : Node
{
    static Dictionary<string, Graph> generatedPanels = new Dictionary<string, Graph>();
    public static int StringHash(string str) {
        uint value = 0;
        foreach (char c in str) {
            value = value * 31 + c;
        }
        return (int)value;
    }
    public static string GeneratePanel(string setName, string name, int seed) {
        GD.Print("Generating " + name);
        string storeKey = setName + "@" + name + "@" + seed;
        if (generatedPanels.ContainsKey(storeKey))
            return generatedPanels[storeKey].ToXML();
        Random globalRng = new Random(seed);
        Random localRng = new Random(StringHash(name) + seed);
        SetGenerator setGenerator;
        if (setName == "Challenge: Normal") 
            setGenerator = new SetGeneratorNormal();
        else if (setName == "Challenge: Normal SC") {
            setGenerator = new SetGeneratorNormal();
        }
        else if (setName == "Challenge: Misc") 
            setGenerator = new SetGeneratorMisc();
        else if (setName == "Challenge: Eliminators")
            setGenerator = new SetGeneratorEliminators();
        else if (setName == "Challenge: Rings")
            setGenerator = new SetGeneratorRings();
        else if (setName == "Challenge: Arrows")
            setGenerator = new SetGeneratorArrows();
        else if (setName == "Challenge: Bee Hive")
            setGenerator = new SetGeneratorHex();
        else if (setName == "Challenge: Finite Water")
            setGenerator = new SetGeneratorFiniteWater();
        else if (setName == "Challenge: Speed")
            setGenerator = new SetGeneratorEasy();
        else if (setName == "Challenge: Antipolynomino")
            setGenerator = new SetGeneratorAntipolynomino();
        else if (setName == "Challenge: Droplets")
            setGenerator = new SetGeneratorDroplets();
        else if (setName == "Challenge: Minesweeper")
            setGenerator = new SetGeneratorMinesweeper();
        else if (setName == "Challenge: Multiple Choices")
            setGenerator = new SetGeneratorMultipleChoices(3);
        else 
            throw new NotImplementedException();
        setGenerator.Init(globalRng);
        while (true) {
            (WitnessGenerator generator, GeneratorFlags flags) = setGenerator.GetGenerator(name, globalRng, localRng);
            flags.MultiSolveVertices = name.Contains("meta1") ? new int[] {
                SetGenerator.GetCornerVertex(generator.Graph, 45).Index,
                SetGenerator.GetCornerVertex(generator.Graph, -135).Index,
            } : null;
            if (generator.MaxTries == -1)  // prevent infinite loop
                generator.MaxTries = 30;
            Graph graph = generator.Sample(localRng, flags);
            if (graph != null) {
                generatedPanels[storeKey] = graph;
                GD.Print("Generated " + name);
                return graph.ToXML();
            }
        }
    }
}
