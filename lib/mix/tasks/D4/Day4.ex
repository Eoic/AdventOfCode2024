defmodule Grid do
  defstruct width: 0, height: 0, matrix: %{}
end

defmodule Mix.Tasks.Day4 do
  require Timer
  require InputUtils

  @needle "XMAS"
  @input "input.txt"
  @directions [:left, :right, :up, :down, :up_left, :up_right, :down_left, :down_right]

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
    |> Enum.reduce(%Grid{}, fn row, state ->
      row
      |> String.graphemes()
      |> Enum.reduce(%{state | height: state.height + 1, width: 0}, fn token, state ->
        %{
          state
          | width: state.width + 1,
            matrix:
              Map.put(
                state.matrix,
                [state.width, state.height - 1],
                <<hd(String.to_charlist(token))>>
              )
        }
      end)
    end)
  end

  defp collect_straight([x_range, y_range], grid) do
    for x <- x_range,
        y <- y_range,
        into: "",
        do: Map.get(grid.matrix, [x, y])
  end

  defp collect_diagonal(x, y, next_position, grid, offset) do
    [chars, _] =
      0..offset
      |> Enum.reduce([[], [x, y]], fn _, [chars, [x, y]] ->
        [[Map.get(grid.matrix, [x, y]) | chars], next_position.(x, y)]
      end)

    Enum.join(chars)
  end

  defp sweep(direction, x, y, grid, offset) do
    case direction do
      :left ->
        if x - offset >= 0, do: collect_straight([x..(x - offset), y..y], grid)

      :right ->
        if x + offset < grid.width, do: collect_straight([x..(x + offset), y..y], grid)

      :up ->
        if y - offset >= 0,
          do: collect_straight([x..x, y..(y - offset)], grid)

      :down ->
        if y + offset < grid.height,
          do: collect_straight([x..x, y..(y + offset)], grid)

      :up_left ->
        if x - offset >= 0 and y - offset >= 0,
          do: collect_diagonal(x, y, &[&1 - 1, &2 - 1], grid, offset)

      :up_right ->
        if x + offset <= grid.width - 1 and y - offset >= 0,
          do: collect_diagonal(x, y, &[&1 + 1, &2 - 1], grid, offset)

      :down_left ->
        if x - offset >= 0 and y + offset < grid.height,
          do: collect_diagonal(x, y, &[&1 - 1, &2 + 1], grid, offset)

      :down_right ->
        if x + offset < grid.width and y + offset < grid.height,
          do: collect_diagonal(x, y, &[&1 + 1, &2 + 1], grid, offset)
    end
  end

  defp count_needles(data) do
    offset = String.length(@needle) - 1

    Enum.reduce(data.matrix, 0, fn {[x, y], _}, sum ->
      @directions
      |> Stream.map(&sweep(&1, x, y, data, offset))
      |> Stream.filter(fn word -> word === @needle end)
      |> Enum.count()
      |> Kernel.+(sum)
    end)
  end

  defp is_valid_diagonal?(positions, grid) do
    diagonal = for [x, y] <- positions, into: "", do: Map.get(grid.matrix, [x, y], "")
    diagonal === "MS" or diagonal === "SM"
  end

  defp is_main_diagonal?(x, y, grid) do
    is_valid_diagonal?([[x - 1, y - 1], [x + 1, y + 1]], grid)
  end

  defp is_secondary_diagonal?(x, y, grid) do
    is_valid_diagonal?([[x + 1, y - 1], [x - 1, y + 1]], grid)
  end

  defp is_valid_shape?(char, x, y, data) do
    char === "A" and is_main_diagonal?(x, y, data) and is_secondary_diagonal?(x, y, data)
  end

  defp count_shapes(data) do
    data.matrix
    |> Enum.reduce(0, fn {[x, y], char}, count ->
      if is_valid_shape?(char, x, y, data), do: count + 1, else: count
    end)
  end

  defp part_one(data), do: count_needles(data)

  defp part_two(data), do: count_shapes(data)

  def run(_) do
    data = parse_input()
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
