#load "structs.fs"
#load "utils.fs"

open Structs
open Utils

let pattern = System.IO.File.ReadAllText "input.txt";
let totalMoves = System.Environment.GetCommandLineArgs()[2] |> int64

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

let getModX (p: int, shape: string) =
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

let getRepeatKey (height: int, p: int, grid: Map<int, Map<int, bool>>) =
    match getLowestHorizontalX(height, grid) with
    | Some(x) -> Some(sprintf "%i-%i" p x)
    | None -> None

let testRepeatKey (key: string option, record: Map<string, int>) =
    match key with
    | Some(key) ->
        match record.TryFind(key) with
        | Some(v) ->
            if v = 1 then (true, false, record.Add(key, 2)) else (false, true, record)
        | None -> (false, false, record.Add(key, 1))
    | None -> (false, false, record)

let rec simulateGrid (rocks: int64, height: int, moves: int, p: int, grid: Map<int, Map<int, bool>>, record: Map<string, int>, repeats: List<int>) =
    match moves with
    | m when int64(m) = rocks -> (height + 1, moves, repeats)
    | m ->
        let nextKey = getRepeatKey(height, p, grid)
        let repeatStarted = repeats.Length > 0
        let (repeatStart, repeatEnd, nextRecord) = testRepeatKey(nextKey, record)
        if repeatEnd then (height + 1, moves, repeats) else
        let rockName = getRockName(m % 5)
        let (modP, modX) = getModX(p, rockName)
        let rock = getRock(rockName, modX, height + 1)
        let (nextHeight, nextP, nextGrid) = simulateRock(rock, modP, grid)
        let resolvedHeight = max nextHeight height
        let nextRepeats = if repeatStart || repeatStarted then List.append repeats [resolvedHeight - height] else repeats
        simulateGrid(rocks, resolvedHeight, moves + 1, nextP, nextGrid, nextRecord, nextRepeats)

let (height, moves, repeats) = simulateGrid(totalMoves, -1, 0, 0, Map.empty, Map.empty, List.empty)

let remainingMoves = totalMoves - int64(moves)
let completeRepeats = int64(List.sum repeats) * (remainingMoves / int64(repeats.Length))
let partialRepeats = int64(List.sum repeats[0..int((remainingMoves % int64(repeats.Length)) - 1L)])
let result = int64(height) + completeRepeats + partialRepeats

printfn "%i" result