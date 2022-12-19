let pattern = System.IO.File.ReadAllText "input.txt";

type Point =
    struct
        val X: int
        val Y: int
        new (x: int, y: int) = {X = x; Y = y}

        member this.Key() =
            sprintf "%i-%i" this.X this.Y

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
        val Name: string
        new (points: Point list, name: string) = {Points = points; Name = name}

        member this.Peek(direction: char) =
            match direction with
            | '<' -> this.Points |> List.map(fun p -> p.ShiftLeft())
            | '>' -> this.Points |> List.map(fun p -> p.ShiftRight())
            | 'd' -> this.Points |> List.map(fun p -> p.ShiftDown())
            | _ -> failwith "provided direction was invalid"

        member this.Move(points: Point list) =
            new Rock(points, this.Name)

        member this.Height() =
            let rec findHeight (points: Point list, highest: int) = 
                match points, highest with
                | [], h -> h
                | x::xs, h ->
                    if h < x.Y then findHeight(xs, x.Y) else findHeight(xs, h)
            findHeight(this.Points, 0)
    end

let getHorizontal (y: int) = new Rock([
    new Point(2, y)
    new Point(3, y)
    new Point(4, y)
    new Point(5, y)
], "Horizontal")

let getCross (y: int) = new Rock([
    new Point(2, y + 1)
    new Point(3, y + 1)
    new Point(3, y)
    new Point(3, y + 2)
    new Point(4, y + 1)
], "Cross")

let getL (y: int) = new Rock([
    new Point(2, y)
    new Point(3, y)
    new Point(4, y)
    new Point(4, y + 1)
    new Point(4, y + 2)
], "L")

let getVertical (y: int) = new Rock([
    new Point(2, y)
    new Point(2, y + 1)
    new Point(2, y + 2)
    new Point(2, y + 3)
], "Vertical")

let getSquare (y: int) = new Rock([
    new Point(2, y)
    new Point (2, y + 1)
    new Point(3, y)
    new Point(3, y + 1)
], "Square")

let getRock (id: int, y: int) =
    match id with
    | 0 -> getHorizontal(y)
    | 1 -> getCross(y)
    | 2 -> getL(y)
    | 3 -> getVertical(y)
    | 4 -> getSquare(y)
    | _ -> failwith "provided id was invalid"

let rec validatePoints (points: Point list, grid: Map<string, Point>) =
    match points with
    | [] -> true
    | x::xs -> 
        if x.X < 0 || x.X > 6 || x.Y < 0 || grid.ContainsKey(x.Key()) 
        then false 
        else validatePoints(xs, grid)

let rec assignPoints (points: Point list, grid: Map<string, Point>) =
    match points with
    | [] -> grid
    | x::xs -> assignPoints(xs, grid.Add(x.Key(), x))

let rec simulateRock (rock: Rock, p: int, grid: Map<string, Point>) =
    let direction = pattern[p]
    let hPoints = rock.Peek(direction)
    match validatePoints(hPoints, grid) with
    | true ->
        let newRock = rock.Move(hPoints)
        let vPoints = newRock.Peek('d')
        match validatePoints(vPoints, grid) with
        | true -> simulateRock(newRock.Move(vPoints), (p + 1) % pattern.Length, grid)
        | false -> (newRock.Height(), (p + 1) % pattern.Length, assignPoints(newRock.Points, grid))
    | false ->
        let vPoints = rock.Peek('d')
        match validatePoints(vPoints, grid) with
        | true -> simulateRock(rock.Move(vPoints), (p + 1) % pattern.Length, grid)
        | false -> (rock.Height(), (p + 1) % pattern.Length, assignPoints(rock.Points, grid))

let rec simulateGrid (rocks: int64, height: int, moves: int, p: int, grid: Map<string, Point>) =
    match moves with
    | m when int64(m) = rocks -> (height + 1, grid)
    | m ->
        if m % 1000000 = 0 then printfn "%i" m
        let rock = getRock(m % 5, height + 4)
        let (nextHeight, nextP, nextGrid) = simulateRock(rock, p, grid)
        simulateGrid(rocks, max nextHeight height, moves + 1, nextP, nextGrid)

let stopWatch = System.Diagnostics.Stopwatch.StartNew()
let (result, grid) = simulateGrid(1000000, -1, 0, 0, Map.empty)
stopWatch.Stop()

printfn "Completed 1000000 rock for part-1 in %f ms" stopWatch.Elapsed.TotalMilliseconds

printfn "%i" result

// for i in result .. -1 .. 0 do
//     for j in 0 .. 6 do
//         let key = sprintf "%i-%i" j i
//         if grid.ContainsKey(key) then printf "#" else printf "."
//     printf "\n"
        