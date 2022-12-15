import { getRanges, getSensors } from './utils';

(async () => {
    const sensors = await getSensors();
    const map = new Map<number, boolean>();

    sensors.forEach((sensor) => sensor.apply(2000000, map));

    let total = 0;

    map.forEach((v) => {
        if (!v) {
            total += 1;
        }
    });

    console.log(total);
})();