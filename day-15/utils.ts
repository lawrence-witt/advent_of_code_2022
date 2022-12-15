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

    apply_1(y: number, map: Map<number, boolean>) {
        const scope = Math.abs(this.x - this.bx) + Math.abs(this.y - this.by);
        if (y <= this.y + scope && y >= this.y - scope) {
            const xPositions = scope - Math.abs(y - this.y);
            for (let x = this.x - xPositions; x <= this.x + xPositions; x++) {
                map.set(x, x === this.bx && y === this.by ? true : false);
            }
        }
    }

    apply_2(y: number, min: number, max: number) {
        const scope = Math.abs(this.x - this.bx) + Math.abs(this.y - this.by);
        if (y <= this.y + scope && y >= this.y - scope) {
            const xPositions = scope - Math.abs(y - this.y);
            return [Math.max(this.x - xPositions, min), Math.min(this.x + xPositions, max)] as const;
        }
        return undefined;
    }

    getMinY() {
        const scope = Math.abs(this.x - this.bx) + Math.abs(this.y - this.by);
        return this.y - scope;
    }

    getMaxY() {
        const scope = Math.abs(this.x - this.bx) + Math.abs(this.y - this.by);
        return this.y + scope;
    }
}