import fs from 'fs';
import readline from 'readline';

export class Node {
    name;
    edges;
    rate;
    paths: Record<string, string[]> = {};

    constructor(name: string, edges: string[], rate: number) {
        this.name = name;
        this.edges = edges;
        this.rate = rate;
    }

    getPath(target: string) {
        return this.paths[target];
    }

    setPath(target: string, path: string[]) {
        this.paths[target] = path;
    }
}

export const getNodes = async () => {
    const rl = readline.createInterface({
        input: fs.createReadStream("input.txt"),
        crlfDelay: Infinity
    })

    const nodes: Record<string, Node> = {};

    for await (const line of rl) {
        const [node, ...edges] = line.slice(1).match(/([A-Z]+)/g)!
        const [rate] = line.match(/(\d+)/g)!;
        nodes[node] = new Node(node, edges, parseInt(rate));
    }

    return nodes;
}

// CONSTRUCTING THE GRAPH

class PriorityQueue {
    elements;

    constructor(elements: [number, string][]) {
        this.elements = elements;
    }

    push(element: [number, string]) {
        this.elements.push(element);
    }

    pop() {
        if (this.isEmpty()) {
            return undefined;
        }
        let index = 0;
        let element: [number, string] | undefined;
        for (let i = 0; i < this.elements.length; i++) {
            if (!element || this.elements[i][0] < element[0]) {
                index = i;
                element = this.elements[i];
            }
        }
        if (element) {
            return this.elements.splice(index, 1)[0];
        }
        return element;
    }

    isEmpty() {
        return this.elements.length === 0;
    }
}

export const getShortestPath = (start: string, end: string, nodes: Record<string, Node>, edges: string[]) => {
    const queue = new PriorityQueue([[0, start]]);
    const edgeMap = edges.reduce((out: Record<string, [number, string]>, edge) => (out[edge] = [Infinity, edge], out), {})
    edgeMap[start] = [0, start];

    const pathMap: Record<string, string> = {};
    let next;

    while((next = queue.pop())) {
        const neighbours = nodes[next[1]].edges;
        for (const n of neighbours) {
            const nEdge = edgeMap[n];
            if (next[0] + 1 < nEdge[0]) {
                pathMap[n] = next[1];
                edgeMap[n] = [next[0] + 1, nEdge[1]];
                queue.push(edgeMap[n])
            }
        }
    }

    let segment = end;
    const path = [];

    do {
        path.push(segment);
        segment = pathMap[segment];
    } while (segment !== start);

    return path.reverse();
}

// SOLVING THE GRAPH

const simulatePath = (source: Node, path: Node[], minutes: number) => {
    const combined = [source, ...path];
    let pressure = 0;
    let released = 0;
    for (let i = 0; i < combined.length -1; i++) {
        const current = combined[i];
        const next = combined[i+1];
        const moves = current.getPath(next.name).length + 1;
        if (minutes - moves <= 0) {
            break;
        }
        minutes -= moves;
        released += moves * pressure;
        pressure += next.rate;
    }
    return released + minutes * pressure;
}

/**
*  Find the position of a node in a given path which produces the highest
*  simulated value. 
*/
const bestPermutation = (source: Node, next: Node, path: Node[], minutes: number) => {
    const simulations = [];
    for (let i = 0; i <= path.length; i++) {
        const test = [...path];
        test.splice(i, 0, next);
        simulations.push({value: simulatePath(source, test, minutes), path: test})
    }
    simulations.sort((a, b) => b.value - a.value);
    return simulations[0];
}

/** 
*   Find the best path through a set of nodes in relation to an initial node.
*/
const solvePath = (source: Node, initial: Node, nodes: Node[], minutes: number) => {
    const remainingNodes = [...nodes];
    let result = {value: simulatePath(source, [initial], minutes), path: [initial]};
    while(remainingNodes.length > 0) {
        const permuations = [];
        for (let i = 0; i < remainingNodes.length; i++) {
            permuations.push([i, bestPermutation(source, remainingNodes[i], result.path, minutes)] as const);
        }
        permuations.sort((a, b) => b[1].value - a[1].value);
        result = permuations[0][1];
        remainingNodes.splice(permuations[0][0], 1);
    }
    return result;
}

export const solveGraph = (source: Node, nodes: Node[], minutes: number) => {
    const results = [];
    for (let i = 0; i < nodes.length; i++) {
        results.push(solvePath(source, nodes[i], [...nodes.slice(0, i), ...nodes.slice(i + 1)], minutes))
    }
    results.sort((a, b) => b.value - a.value);
    return results[0];
}