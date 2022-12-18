import { Node, getNodes, getShortestPath, solveGraph } from "./utils"

const uniquePairs = (nodes: Node[]) => {
    const sizeOne = Math.floor(nodes.length / 2);
    const sizeTwo = Math.ceil(nodes.length / 2);
    const combine = (
        arr: Node[], 
        size: number,  
        output: any[] = [],
        index: number = 0, 
        data: any[] = Array.from({length: size}), 
        i: number = 0, 
    ) => {
        if (index === size) {
            output.push(data);
            return;
        }
        if (i >= arr.length) {
            return;
        }
        data[index] = arr[i];
        combine(arr, size, output, index + 1, [...data], i + 1);
        combine(arr, size, output, index, [...data], i + 1);
    }
    const outputOne: Node[][] = [];
    const outputTwo: Node[][] = [];
    combine(nodes, sizeOne, outputOne);
    combine(nodes, sizeTwo, outputTwo);
    return [outputOne, outputTwo] as const;
}

(async () => {
    const nodes = await getNodes();

    const nodeNames = Object.values(nodes).map((node) => node.name);

    for (const start of nodeNames) {
        const otherNames = nodeNames.filter(on => on !== start);
        for (const end of otherNames) {
            nodes[start].setPath(end, getShortestPath(start, end, nodes, otherNames));
        }
    }

    let ratedNodes = Object.values(nodes).filter((node) => node.rate > 0);

    const [first, second] = uniquePairs(ratedNodes);

    const results = [];

    for (let i = 0; i < first.length; i++) {
        for (let j = i; j < second.length; j++) {
            const human = first[i];
            const elephant = second[j];
            if (new Set([...human, ...elephant]).size !== human.length + elephant.length) {
                continue;
            }
            const humanResult = solveGraph(nodes.AA, human, 26);
            const elephantResult = solveGraph(nodes.AA, elephant, 26);
            results.push({value: humanResult.value + elephantResult.value, human: humanResult, elephant: elephantResult});
        }
    }

    results.sort((a, b) => b.value - a.value);

    console.log(results[0].value, results[0].human.path.map((n) => n.name), results[0].elephant.path.map((n) => n.name));
})()