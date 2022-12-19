let pattern = System.IO.File.ReadAllText "input.txt";

let clamp (mn: int, pref: int, mx: int) =
    max mn (min pref mx)

type Point =
    struct
        val X: int
        val Y: int
        new (x: int, y: int) = {X = x; Y = y}

        member this.ShiftLeft() =
            new Point(this.X - 1, this.Y)

        member this.ShiftRight() =
            new Point(this.X + 1, this.Y)

        member this.ShiftDown() =
            new Point(this.X, this.Y - 1)
    end

type Rock =
    struct
        val Points: Point list
        val Left: int list
        val Right: int list
        val Down: int list
        val Name: string
        new (points: Point list, left: int list, right: int list, down: int list, name: string) = 
            {Points = points; Name = name; Left = left; Right = right; Down = down}

        member this.Peek(direction: char) =
            let self = this
            match direction with
            | '<' -> this.Left |> List.map(fun p -> self.Points[p].ShiftLeft())
            | '>' -> this.Right |> List.map(fun p -> self.Points[p].ShiftRight())
            | 'd' -> this.Down |> List.map(fun p -> self.Points[p].ShiftDown())
            | _ -> failwith "provided direction was invalid"

        member this.Move(direction: char) =
            match direction with
            | '<' -> new Rock(this.Points |> List.map(fun p -> p.ShiftLeft()), this.Left, this.Right, this.Down, this.Name)
            | '>' -> new Rock(this.Points |> List.map(fun p -> p.ShiftRight()), this.Left, this.Right, this.Down, this.Name)
            | 'd' -> new Rock(this.Points |> List.map(fun p -> p.ShiftDown()), this.Left, this.Right, this.Down, this.Name)
            | _ -> failwith "provided direction was invalid"

        member this.Height() =
            let rec findHeight (points: Point list, highest: int) = 
                match points, highest with
                | [], h -> h
                | x::xs, h ->
                    if h < x.Y then findHeight(xs, x.Y) else findHeight(xs, h)
            findHeight(this.Points, 0)
    end

let getHorizontal (x: int, y: int) = 
    new Rock([
        new Point(x, y)
        new Point(x + 1, y)
        new Point(x + 2, y)
        new Point(x + 3, y)
    ],[0], [3], [0; 1; 2; 3], "Horizontal")

let getCross (x: int, y: int) =
    new Rock([
        new Point(x, y + 1)
        new Point(x + 1, y)
        new Point(x + 1, y + 1)
        new Point(x + 1, y + 2)
        new Point(x + 2, y + 1)
    ], [0; 1; 3], [1; 3; 4], [0; 1; 4], "Cross")

let getL (x: int, y: int) = 
    new Rock([
        new Point(x, y)
        new Point(x + 1, y)
        new Point(x + 2, y)
        new Point(x + 2, y + 1)
        new Point(x + 2, y + 2)
    ], [0; 3; 4], [2; 3; 4], [0; 1; 2], "L")

let getVertical (x: int, y: int) = 
    new Rock([
        new Point(x, y)
        new Point(x, y + 1)
        new Point(x, y + 2)
        new Point(x, y + 3)
    ], [0; 1; 2; 3], [0; 1; 2; 3], [0], "Vertical")

let getSquare (x: int, y: int) = 
    new Rock([
        new Point(x, y)
        new Point (x, y + 1)
        new Point(x + 1, y)
        new Point(x + 1, y + 1)
    ], [0; 1], [2; 3], [0; 2], "Square")

let getRockName (id: int) =
    match id with
    | 0 -> "Horizontal"
    | 1 -> "Cross"
    | 2 -> "L"
    | 3 -> "Vertical"
    | 4 -> "Square"
    | _ -> failwith "provided id was invalid"

let getRock (name: string, x: int, y: int) =
    match name with
    | "Horizontal" -> getHorizontal(x, y)
    | "Cross" -> getCross(x, y)
    | "L" -> getL(x, y)
    | "Vertical" -> getVertical(x, y)
    | "Square" -> getSquare(x, y)
    | _ -> failwith "provided name was invalid"

let rec validatePoints (points: Point list, grid: Map<int, Map<int, bool>>) =
    match points with
    | [] -> true
    | p::ps ->
        match p.X, p.Y with
        | x, y when x >= 0 && x <= 6 && y >= 0 ->
            match grid.TryFind(p.Y) with
            | Some(keys) -> 
                if keys.ContainsKey(p.X) then false else validatePoints(ps, grid)
            | None -> validatePoints(ps, grid)
        | _, _ -> false


let rec assignPoints (points: Point list, grid: Map<int, Map<int, bool>>) =
    match points with
    | [] -> grid
    | p::ps ->
        match grid.TryFind(p.Y) with
        | Some(keys) -> 
            let nextGrid = grid.Add(p.Y, keys.Add(p.X, true))
            assignPoints(ps, nextGrid)
        | None -> assignPoints(points, grid.Add(p.Y, Map.empty))

let rec simulateRock (rock: Rock, p: int, grid: Map<int, Map<int, bool>>) =
    let direction = pattern[p]
    match validatePoints(rock.Peek(direction), grid) with
    | true ->
        let newRock = rock.Move(direction)
        match validatePoints(newRock.Peek('d'), grid) with
        | true -> simulateRock(newRock.Move('d'), (p + 1) % pattern.Length, grid)
        | false -> (newRock.Height(), (p + 1) % pattern.Length, assignPoints(newRock.Points, grid))
    | false ->
        match validatePoints(rock.Peek('d'), grid) with
        | true -> simulateRock(rock.Move('d'), (p + 1) % pattern.Length, grid)
        | false -> (rock.Height(), (p + 1) % pattern.Length, assignPoints(rock.Points, grid))

let getXMod (p: int, shape: string) =
    let maxX = 
        match shape with
        | "Horizontal" -> 3
        | "Cross" | "L" -> 4
        | "Vertical" -> 6
        | "Square" -> 5
        | _ -> failwith "invalid shape was provided"
    let rec _getXMod (p: int, remaining: int, xMod: int) =
        match remaining with
        | 0 -> (p, xMod)
        | r ->
            let next = if pattern[p] = '<' then -1 else 1;
            _getXMod((p + 1) % pattern.Length, r - 1, clamp(0, xMod + next, maxX))
    _getXMod(p, 3, 2)


let getLowestHorizontalX (height: int, grid: Map<int, Map<int, bool>>) =
    match grid.TryFind(height) with
    | Some(keys) ->
        if not (keys.Count = 4) then None else (
            Some(List.min (keys.Keys |> Seq.cast |> List.ofSeq))
        )
    | None -> None

let rec simulateGrid (rocks: int64, height: int, moves: int, p: int, grid: Map<int, Map<int, bool>>, record: Map<string, bool>) =
    match moves with
    | m when int64(m) = rocks -> (height + 1, grid)
    | m ->
        if m % 1000000 = 0 then printfn "%i" m
        let rockName = getRockName(m % 5)

        let crossKey = 
            match getLowestHorizontalX(height, grid) with
            | Some(x) -> Some(sprintf "%i %i" p x)
            | None -> None

        let nextRecord = 
            match crossKey with
            | Some(key) -> 
                if record.ContainsKey(key) then 
                    printfn "%s exists at move %i" key m
                    record
                else 
                    record.Add(key, true)
            | None -> record

        let (modP, xMod) = getXMod(p, rockName)
        let rock = getRock(rockName, xMod, height + 1)
        let (nextHeight, nextP, nextGrid) = simulateRock(rock, modP, grid)
        simulateGrid(rocks, max nextHeight height, moves + 1, nextP, nextGrid, nextRecord)

let (result, grid) = simulateGrid(10000, -1, 0, 0, Map.empty, Map.empty)

printfn "%i" result

// System.IO.File.Delete("./part-2-output.txt")
// System.IO.File.AppendAllText("./part-2-output.txt", "");

// for i in result - 1 .. -1 .. 0 do
//     match grid.TryFind(i) with
//     | Some(keys) ->
//         for j in 0 .. 6 do
//             if keys.ContainsKey(j) then System.IO.File.AppendAllText("./part-2-output.txt", "#") else System.IO.File.AppendAllText("./part-2-output.txt", ".")
//     | None -> printf ""
//     System.IO.File.AppendAllText("./part-2-output.txt", "\n")