module Utils

open Structs

let clamp (mn: int, pref: int, mx: int) =
    max mn (min pref mx)

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