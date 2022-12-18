import { Node, getNodes, getShortestPath, solveGraph } from "./utils"

(async () => {
    const nodes = await getNodes();

    const nodeNames = Object.values(nodes).map((node) => node.name);

    for (const start of nodeNames) {
        const otherNames = nodeNames.filter(on => on !== start);
        for (const end of otherNames) {
            nodes[start].setPath(end, getShortestPath(start, end, nodes, otherNames));
        }
    }

    const ratedNodes = Object.values(nodes).filter((node) => node.rate > 0);

    const result = solveGraph(nodes.AA, ratedNodes, 30);

    console.log(result.value);
})()