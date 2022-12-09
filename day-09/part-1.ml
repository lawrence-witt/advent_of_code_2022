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
  | _ -> (tx, ty)


let rec process_command direction moves ctx =
  match direction, moves, ctx with
  | d, 0, c -> ctx
  | d, m, (head, tail, set) ->
    let new_head = update_head head d in
    let (tx, ty) = update_tail new_head tail in
    let tail_key = Format.sprintf "%i %i" tx ty in
    let new_set = SS.add tail_key set in
    process_command d (m-1) (new_head, (tx, ty), new_set)

let process_line line ctx =
  let parsed = parse_line line in
  match parsed with
    | Some (direction, moves) -> process_command direction moves ctx
    | None -> ctx;;

let process_lines file process ctx =
  let in_ch = open_in file in
  let rec read_line ctx () =
    let line = try Some(input_line in_ch) with End_of_file -> None
    in
      match line with
      | Some (l) -> read_line (process l ctx) ();
      | None -> ctx
  in read_line ctx ();;

let (_, _, set) = process_lines "input.txt" process_line ((0, 0), (0, 0), SS.singleton "0 0");;

print_endline (string_of_int (SS.cardinal set))