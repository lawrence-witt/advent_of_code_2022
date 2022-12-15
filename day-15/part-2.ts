import { getRanges, getSensors } from './utils';

const MIN = 0;
const MAX = 4000000;

const testRanges = (ranges: (readonly [number, number])[]) => {
    const sortedRanges = [...ranges].sort((a, b) => a[0] - b[0]);
    let max = sortedRanges[0][1];
    for (let i = 1; i < sortedRanges.length; i++) {
        const r = sortedRanges[i];
        if (r[0] - max === 2) {
            return r[0] - 1;
        } else {
            max = Math.max(r[1], max);
        }
    }
    return undefined;
}

(async () => {
    const sensors = await getSensors();

    for (let y = MIN; y <= MAX; y++) {
        const ranges = getRanges(sensors, y, MIN, MAX);
        const result = testRanges(ranges);
        if (result) {
            console.log((result * MAX) + y);
            return;
        }
    }
})();