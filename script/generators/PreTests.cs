using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WitnessInfinite;
using Decorators = WitnessInfinite.Decorators;

class PreTests {
    public static bool VertexSquareColorTest(Graph Graph) {
        foreach (Vertex vertex in Graph.Vertices) {
            if (vertex.ConnectedEdges != null) {
                int sepCount = 0;
                foreach (Edge edge in vertex.ConnectedEdges) {
                    if (edge.SharedFacets.Count >= 2) {
                        if (edge.SharedFacets[0].CenterVertex.Decorator is Decorators.SquareDecorator squareDecorator0 &&
                            edge.SharedFacets[1].CenterVertex.Decorator is Decorators.SquareDecorator squareDecorator1) {
                            if (squareDecorator0.Color != squareDecorator1.Color) {
                                sepCount += 1;
                            }
                        }
                    }
                }
                if (sepCount >= 2)
                    return false;
            }
        }
        return true;
    }
}
