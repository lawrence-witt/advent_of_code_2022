defmodule Cube do
  defstruct x: 0, y: 0, z: 0, visible_sides: 6

  @spec create(String.t()) :: Cube
  def create(str) do
    groups = Regex.named_captures(~r/(?<x>\d+),(?<y>\d+),(?<z>\d+)/, str)
    %Cube{x: String.to_integer(groups["x"]), y: String.to_integer(groups["y"]), z: String.to_integer(groups["z"])}
  end

  @spec adjacent(Cube, Cube) :: boolean()
  def adjacent(c1, c2) do
    sameX = c1.x === c2.x
    sameY = c1.y === c2.y
    sameZ = c1.z === c2.z
    adjacentX = sameY && sameZ && (c1.x + 1 === c2.x || c1.x - 1 === c2.x)
    adjacentY = sameX && sameZ && (c1.y + 1 === c2.y || c1.y - 1 === c2.y)
    adjacentZ = sameX && sameY && (c1.z + 1 === c2.z || c1.z - 1 === c2.z)
    adjacentX || adjacentY || adjacentZ
  end

  @spec connect(Cube, Cube) :: {Cube, Cube}
  def connect(c1, c2) do
    {
      %Cube{x: c1.x, y: c1.y, z: c1.z, visible_sides: c1.visible_sides - 1},
      %Cube{x: c2.x, y: c2.y, z: c2.z, visible_sides: c2.visible_sides - 1}
    }
  end
end

defmodule Simulation do
  @spec run(list(Cube)) :: list(Cube)
  def run(cubes) do
    run_outer(cubes, [])
  end

  @spec run_outer(list(Cube), list(Cube)) :: list(Cube)
  defp run_outer(remaining, complete) do
    case remaining do
      [] -> complete
      [h | t] ->
        {f, s} = run_inner(h, t, [])
        run_outer(s, [f | complete])
    end
  end

  @spec run_inner(Cube, list(Cube), list(Cube)) :: list(Cube)
  defp run_inner(test, remaining, complete) do
    case remaining do
      [] -> {test, complete}
      [h | t] ->
        adjacent = Cube.adjacent(test, h)
        {c1, c2} = if adjacent, do: Cube.connect(test, h), else: {test, h}
        run_inner(c1, t, [c2 | complete])
    end
  end
end

cubes =
  File.stream!("./input.txt")
  |> Stream.map(&Cube.create/1)
  |> Enum.to_list()

processed_cubes =
  Simulation.run(cubes)

result = Enum.reduce(processed_cubes, 0, fn x, acc -> x.visible_sides + acc end)

IO.puts(result)
