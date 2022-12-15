import fs from 'fs';
import readline from 'readline';

const TY = 2000000;

(async () => {
    const rl = readline.createInterface({
        input: fs.createReadStream("./input.txt"),
        crlfDelay: Infinity
    })

    const expr = /(-?\d+)/g
    const map = new Map<number, boolean>();

    for await (const line of rl) {
        const [sx, sy, bx, by] = line.match(expr)!.map(Number);
        const scope = Math.abs(sx - bx) + Math.abs(sy - by);
        if (TY <= sy + scope && TY >= sy - scope) {
            const xPositions = scope - Math.abs(TY - sy);
            for (let x = sx - xPositions; x <= sx + xPositions; x++) {
                map.set(x, x === bx && TY === by ? true : false);
            }
        }
    }

    let total = 0;

    map.forEach((v) => {
        if (!v) {
            total += 1;
        }
    });

    console.log(total);
})();