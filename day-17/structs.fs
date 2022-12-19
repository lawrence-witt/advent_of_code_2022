module Structs

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