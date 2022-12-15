import fs from 'fs';
import readline from 'readline';
import { Sensor } from './utils';

const FILE = './input.txt';
const MIN = 0;
const MAX = 4000000;

const flattenRanges = (ranges: (readonly [number, number])[]) => {
    const sortedRanges = [...ranges].sort((a, b) => a[0] - b[0]);
    let max = 0;
    for (let i = 0; i < sortedRanges.length; i++) {
        const r = sortedRanges[i];
        if (i === 0) {
            max = r[1];
        } else {
            if (r[0] - max === 2) {
                return r[0] - 1;
            } else {
                max = Math.max(r[1], max);
            }
        }
    }
    return undefined;
}

(async () => {
    const rl = readline.createInterface({
        input: fs.createReadStream(FILE),
        crlfDelay: Infinity
    })

    const expr = /(-?\d+)/g
    const sensors: Sensor[] = [];

    for await (const line of rl) {
        const [sx, sy, bx, by] = line.match(expr)!.map(Number);
        const sensor = new Sensor(sx, sy, bx, by);
        sensors.push(sensor);
    }

    for (let y = MIN; y <= MAX; y++) {
        const ranges = sensors.reduce((out: (readonly [number, number])[], sensor) => {
            const r = sensor.apply_2(y, MIN, MAX);
            if (r) {
                out.push(r);
            }
            return out;
        }, []);

        const result = flattenRanges(ranges);

        if (typeof result !== "undefined") {
            console.log("result: ", (result * 4000000) + y);
            return;
        }
    }
})();