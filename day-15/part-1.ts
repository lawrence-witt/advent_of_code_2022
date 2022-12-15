import fs from 'fs';
import readline from 'readline';
import { Sensor } from './utils';

const fakeY = 10;
const realY = 2000000;

(async () => {
    const rl = readline.createInterface({
        input: fs.createReadStream("./input.txt"),
        crlfDelay: Infinity
    })

    const expr = /(-?\d+)/g
    const map = new Map<number, boolean>();

    const sensors: Sensor[] = [];

    for await (const line of rl) {
        const [sx, sy, bx, by] = line.match(expr)!.map(Number);
        sensors.push(new Sensor(sx, sy, bx, by));
    }

    sensors.forEach((sensor) => sensor.apply_1(realY, map));

    let total = 0;

    map.forEach((v) => {
        if (!v) {
            total += 1;
        }
    });

    console.log(total);
})();