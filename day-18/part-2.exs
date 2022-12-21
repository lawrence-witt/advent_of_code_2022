defmodule Bounds do
  defstruct x: 0, y: 0, z: 0

  @spec calculate(list(Cubes), integer(), integer(), integer()) :: Bounds
  def calculate(cubes, maxX, maxY, maxZ) do
    case cubes do
      [] -> %Bounds{x: maxX, y: maxY, z: maxZ}
      [h | t] -> calculate(t, max(maxX, h.x), max(maxY, h.y), max(maxZ, h.z))
    end
  end
end

defmodule Cube do
  #                                   x+1   x-1   y+1   y-1   z+1   z-1
  defstruct x: 0, y: 0, z: 0, sides: [true, true, true, true, true, true]

  @spec decode(String.t()) :: Cube
  def decode(str) do
    groups = Regex.named_captures(~r/(?<x>-?\d+),(?<y>-?\d+),(?<z>-?\d+)/, str)
    %Cube{x: String.to_integer(groups["x"]), y: String.to_integer(groups["y"]), z: String.to_integer(groups["z"])}
  end

  @spec encode(Cube) :: String.t()
  def encode(cube) do
    "#{cube.x},#{cube.y},#{cube.z}"
  end

  @spec encode_neighbours(Cube) :: list(String.t())
  def encode_neighbours(cube) do
    [
      "#{cube.x + 1},#{cube.y},#{cube.z}",
      "#{cube.x - 1},#{cube.y},#{cube.z}",
      "#{cube.x},#{cube.y + 1},#{cube.z}",
      "#{cube.x},#{cube.y - 1},#{cube.z}",
      "#{cube.x},#{cube.y},#{cube.z + 1}",
      "#{cube.x},#{cube.y},#{cube.z - 1}",
    ]
  end

  @spec hide_side(Cube, integer()) :: Cube
  def hide_side(cube, index) do
    %Cube{x: cube.x, y: cube.y, z: cube.z, sides: List.replace_at(cube.sides, index, false)}
  end

  @spec sum_visible_sides(Cube) :: integer()
  def sum_visible_sides(cube) do
    Enum.reduce(cube.sides, 0, fn x, acc -> if x, do: acc + 1, else: acc end)
  end

  @spec connect(Cube, Cube) :: {Cube, Cube}
  def connect(c1, c2) do
    sameX = c1.x === c2.x
    sameY = c1.y === c2.y
    sameZ = c1.z === c2.z
    c1Right = c1.x - 1 === c2.x
    c1Left = c1.x + 1 === c2.x
    c1Above = c1.y - 1 === c2.y
    c1Below = c1.y + 1 === c2.y
    c1Before = c1.z + 1 === c2.z
    c1After = c1.z - 1 === c2.z
    case {sameX, sameY, sameZ} do
      {false, true, true} ->
        case {c1Left, c1Right} do
          {true, false} -> {hide_side(c1, 0), hide_side(c2, 1)}
          {false, true} -> {hide_side(c1, 1), hide_side(c2, 0)}
          {_, _} -> {c1, c2}
        end
      {true, false, true} ->
        case {c1Below, c1Above} do
          {true, false} -> {hide_side(c1, 2), hide_side(c2, 3)}
          {false, true} -> {hide_side(c1, 3), hide_side(c2, 2)}
          {_, _} -> {c1, c2}
        end
      {true, true, false} ->
        case {c1Before, c1After} do
          {true, false} -> {hide_side(c1, 4), hide_side(c2, 5)}
          {false, true} -> {hide_side(c1, 5), hide_side(c2, 4)}
          {_, _} -> {c1, c2}
        end
      {_, _, _} -> {c1, c2}
    end
  end

  def shift(cube, edge) do
    case edge do
      0 -> %Cube{x: cube.x + 1, y: cube.y, z: cube.z}
      1 -> %Cube{x: cube.x - 1, y: cube.y, z: cube.z}
      2 -> %Cube{x: cube.x, y: cube.y + 1, z: cube.z}
      3 -> %Cube{x: cube.x, y: cube.y - 1, z: cube.z}
      4 -> %Cube{x: cube.x, y: cube.y, z: cube.z + 1}
      5 -> %Cube{x: cube.x, y: cube.y, z: cube.z - 1}
      _ -> raise "invalid edge"
    end
  end
end

defmodule Simulation do
  @occupied 0
  @enclosed 1
  @exposed 2

  @spec connect_cubes(list(Cube), list(Cube)) :: list(Cube)
  def connect_cubes(remaining, connected) do
    case remaining do
      [] -> connected
      [h | t] ->
        {f, s} = connect_cube(h, t, [])
        connect_cubes(s, [f | connected])
    end
  end

  @spec connect_cube(Cube, list(Cube), list(Cube)) :: {Cube, list(Cube)}
  defp connect_cube(test, remaining, connected) do
    case remaining do
      [] -> {test, connected}
      [h | t] ->
        {c1, c2} = Cube.connect(test, h)
        connect_cube(c1, t, [c2 | connected])
    end
  end

  @spec collect_cubes(list(Cube), list(Cube), map()) :: {list(Cube), map()}
  def collect_cubes(cubes, collected, mapping) do
    case cubes do
      [] -> {collected, mapping}
      [h | t] -> collect_cubes(t, collect_cube(h, h.sides, []) ++ collected, Map.put(mapping, Cube.encode(h), @occupied))
    end
  end

  @spec collect_cube(list(Cube), integer(), list(Cube)) :: list(Cube)
  defp collect_cube(cube, remaining, collected) do
    case {remaining, length(remaining)} do
      {[], _} -> collected
      {[h | t], v} -> if h, do: collect_cube(cube, t, [Cube.shift(cube, 6 - v)| collected]), else: collect_cube(cube, t, collected)
      {_, _} -> collected
    end
  end

  @spec explore_cubes(list(Cube), map(), integer(), Bounds) :: {map(), integer()}
  def explore_cubes(cubes, mapping, result, bounds) do
    case cubes do
      [] -> {mapping, result}
      [h | t] ->
        {is_exposed, result_mapping, visited_mapping} = explore_cube(h, mapping, Map.new(), bounds)
        r = if is_exposed, do: 0, else: 1
        next_mapping = case is_exposed do
          true -> merge_mappings(result_mapping, visited_mapping, @exposed)
          false -> merge_mappings(result_mapping, visited_mapping, @enclosed)
        end
        explore_cubes(t, next_mapping, result + r, bounds)
    end
  end

  @spec explore_cube(Cube, map(), map(), Bounds) :: {boolean(), map(), map()}
  defp explore_cube(cube, result_mapping, visited_mapping, bounds) do
    case Map.get(result_mapping, Cube.encode(cube)) do
      @enclosed -> {false, merge_mappings(result_mapping, visited_mapping, @enclosed), visited_mapping}
      @exposed -> {true, merge_mappings(result_mapping, visited_mapping, @exposed), visited_mapping}
      _ ->
        visited_cube_mapping = Map.put(visited_mapping, Cube.encode(cube), true)
        neighbours = available_neighbours(Cube.encode_neighbours(cube), result_mapping, visited_cube_mapping, [])
        case length(neighbours) do
          0 ->
            {false, result_mapping, visited_cube_mapping}
          _ ->
            case is_outside_bounds(neighbours, bounds) do
              true -> {true, merge_mappings(result_mapping, visited_cube_mapping, @exposed), visited_cube_mapping}
              false -> explore_neighbours(neighbours, false, result_mapping, visited_cube_mapping, bounds)
            end
        end
    end
  end

  @spec explore_neighbours(list(Cube), boolean(), map(), map(), Bounds) :: {boolean(), map(), map()}
  defp explore_neighbours(neighbours, is_exposed, result_mapping, visited_mapping, bounds) do
    case neighbours do
      [] -> {is_exposed, result_mapping, visited_mapping}
      [h | t] ->
        {e, r, v} = explore_cube(h, result_mapping, visited_mapping, bounds)
        case e do
          true -> {true, Map.merge(result_mapping, r), Map.merge(visited_mapping, v)}
          false -> explore_neighbours(t, false, Map.merge(result_mapping, r), Map.merge(visited_mapping, v), bounds)
        end
    end
  end

  @spec is_outside_bounds(list(Cube), Bounds) :: boolean()
  defp is_outside_bounds(neighbours, bounds) do
    case neighbours do
      [] -> false
      [h | t] ->
        if h.x < 0 || h.x > bounds.x || h.y < 0 || h.y > bounds.y || h.z < 0 || h.z > bounds.z,
        do: true, else: is_outside_bounds(t, bounds)
    end
  end

  @spec available_neighbours(list(String.t()), map(), map(), list(Cube)) :: list(Cube)
  def available_neighbours(neighbour_keys, result_mapping, visited_mapping, available) do
    case neighbour_keys do
      [] -> available
      [h | t] ->
        case Map.has_key?(visited_mapping, h) do
          true -> available_neighbours(t, result_mapping, visited_mapping, available)
          false ->
            case Map.get(result_mapping, h) do
              @occupied -> available_neighbours(t, result_mapping, visited_mapping, available)
              _ -> available_neighbours(t, result_mapping, visited_mapping, [Cube.decode(h) | available])
            end
        end
    end
  end

  @spec merge_mappings(map(), map(), integer()) :: map()
  defp merge_mappings(result_mapping, visited_mapping, value) do
    case Map.keys(visited_mapping) do
      [] -> result_mapping
      [h | _] -> merge_mappings(Map.put(result_mapping, h, value), Map.delete(visited_mapping, h), value)
    end
  end
end

defmodule Main do
  def main do
    cubes =
      File.stream!("./input.txt")
      |> Stream.map(&Cube.decode/1)
      |> Enum.to_list()

    bounds =
      Bounds.calculate(cubes, 0, 0, 0)

    connected_cubes =
      Simulation.connect_cubes(cubes, [])

    surface_area =
      Enum.reduce(connected_cubes, 0, fn x, acc -> Cube.sum_visible_sides(x) + acc end)

    {collected_cubes, mapping} =
      Simulation.collect_cubes(connected_cubes, [], Map.new())

    {_, enclosed_surface_area} =
      Simulation.explore_cubes(collected_cubes, mapping, 0, bounds)

    IO.puts(surface_area - enclosed_surface_area)
  end
end

Main.main()
