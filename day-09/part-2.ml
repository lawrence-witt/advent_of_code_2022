#load "str.cma";;
module SS = Set.Make(String)

let parse_line (line : string) : (string * int) option =
  let expr = Str.regexp {|\([U|D|L|R]\) \([0-9]+\)|} in
  if Str.string_match expr line 0 then
    let direction = Str.matched_group 1 line in
    let moves = Str.matched_group 2 line in
    Some (direction, int_of_string moves)
  else
    None;;

let get_key (x, y) = Format.sprintf "%i %i" x y

let rec print_knots knots i =
  match knots, i with
  | k :: rest, count ->
    Printf.printf "%i(%s) " count (get_key k);
    print_knots rest (i + 1)
  | _ -> 
    print_endline "";
    []

let update_head head direction =
  match head, direction with
  | (x, y), "U" -> (x, y + 1)
  | (x, y), "D" -> (x, y - 1)
  | (x, y), "L" -> (x - 1, y)
  | (x, y), "R" -> (x + 1, y)
  | _ -> head

let update_tail (hx, hy) (tx, ty) =
  let abs_x = abs (hx - tx) in
  let abs_y = abs (hy - ty) in
  match abs_x, abs_y with
  | 0, 2 -> (tx, hy + ((ty - hy) / 2))
  | 2, 0 -> (hx + ((tx - hx) / 2), ty)
  | 1, 2 -> (hx, hy + ((ty - hy) / 2))
  | 2, 1 -> (hx + ((tx - hx) / 2), hy)
  | 2, 2 -> (hx + ((tx - hx) / 2), hy + ((ty - hy) / 2))
  | _ -> (tx, ty)

let rec process_rope direction unvisited visited calls =
  match unvisited, visited with
  | [], [] -> []
  | [], v -> List.rev v
  | u1 :: urest, [] -> 
    let new_head = update_head u1 direction in
    process_rope direction urest [new_head] (calls + 1)
  | [u1], v1 :: vrest ->
    let new_tail = update_tail v1 u1 in
    process_rope direction [] (new_tail :: v1 :: vrest) (calls + 1)
  | u1 :: urest, [v1] ->
    let new_tail = update_tail v1 u1 in
    process_rope direction urest [new_tail; v1] (calls + 1)
  | u1 :: urest, v1 :: vrest ->
    let new_tail = update_tail v1 u1 in
    process_rope direction urest (new_tail :: v1 :: vrest) (calls + 1)

let rec process_command direction moves ctx =
  match direction, moves, ctx with
  | d, 0, (knots, set) ->
    (knots, set)
  | d, m, (knots, set) ->
    let new_knots = process_rope direction knots [] 0 in
    let tail_knot = List.nth new_knots ((List.length new_knots) - 1) in
    let new_set = SS.add (get_key tail_knot) set in
    process_command d (m-1) (new_knots, new_set)

let process_line line ctx =
  let parsed = parse_line line in
  match parsed with
    | Some (direction, moves) -> process_command direction moves ctx
    | None -> ctx;;

let process_lines file ctx =
  let in_ch = open_in file in
  let rec read_line c () =
    let line = try Some(input_line in_ch) with End_of_file -> None in
    match line with
      | Some (l) -> read_line (process_line l c) ();
      | None -> c
in read_line ctx ();;

let rec get_knots ?(knots = []) count =
  match knots, count with
  | t, 0 -> t
  | [], c -> get_knots ~knots:[(0, 0)] (c-1)
  | t, c -> get_knots ~knots:((0, 0) :: t) (c-1)

let (_, set) = process_lines "input.txt" (get_knots 10, SS.singleton (get_key (0, 0)));;

print_endline (string_of_int (SS.cardinal set))