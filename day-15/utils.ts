import fs from 'fs';
import readline from 'readline';

const FILE = './input.txt';

export class Sensor {
    x;
    y;
    bx;
    by;

    constructor(x: number, y: number, bx: number, by: number) {
        this.x = x;
        this.y = y;
        this.bx = bx;
        this.by = by;
    }

    apply(y: number, map: Map<number, boolean>) {
        const scope = Math.abs(this.x - this.bx) + Math.abs(this.y - this.by);
        if (y <= this.y + scope && y >= this.y - scope) {
            const xPositions = scope - Math.abs(y - this.y);
            for (let x = this.x - xPositions; x <= this.x + xPositions; x++) {
                map.set(x, x === this.bx && y === this.by ? true : false);
            }
        }
    }

    range(y: number, min: number, max: number) {
        const scope = Math.abs(this.x - this.bx) + Math.abs(this.y - this.by);
        if (y <= this.y + scope && y >= this.y - scope) {
            const xPositions = scope - Math.abs(y - this.y);
            return [Math.max(this.x - xPositions, min), Math.min(this.x + xPositions, max)] as const;
        }
        return undefined;
    }
}

export const getSensors = async () => {
    const rl = readline.createInterface({
        input: fs.createReadStream("input.txt"),
        crlfDelay: Infinity
    })

    const expr = /(-?\d+)/g
    const sensors: Sensor[] = [];

    for await (const line of rl) {
        const [sx, sy, bx, by] = line.match(expr)!.map(Number);
        const sensor = new Sensor(sx, sy, bx, by);
        sensors.push(sensor);
    }

    return sensors;
}

export const getRanges = (sensors: Sensor[], y: number, min: number, max: number) => {
    return sensors.reduce((out: (readonly [number, number])[], sensor) => {
        const r = sensor.range(y, min, max);
        if (r) {
            out.push(r);
        }
        return out;
    }, []);
}