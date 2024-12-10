defmodule MemoryMap do
  defstruct position: 0, file_index: 0, blocks: [], free: []
end

defmodule Mix.Tasks.Day9 do
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_all(@input)
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(%MemoryMap{}, fn {size, index}, table ->
      size = String.to_integer(size)
      indices = table.position..(table.position + size - 1)//1 |> Enum.to_list()

      if rem(index, 2) === 0 do
        %{
          table
          | position: table.position + size,
            blocks: [{table.file_index, indices} | table.blocks],
            file_index: table.file_index + 1
        }
      else
        %{
          table
          | position: table.position + size,
            free: table.free ++ [indices]
        }
      end
    end)

    # |> IO.inspect(charlists: :as_lists, limit: :infinity)
  end

  defp checksum(blocks) do
    Enum.reduce(blocks, 0, fn {file_index, positions}, total ->
      total + Enum.reduce(positions, 0, fn position, sum -> sum + position * file_index end)
    end)
  end

  defp part_one(data) do
    data.blocks
    |> Enum.reduce_while(
      %{free: Enum.flat_map(data.free, fn fr -> fr end), blocks: []},
      fn {file_index,
          block_indices = [
            block_head
            | _block_tail
          ]},
         state ->
        if block_head <= hd(state.free) do
          {:cont, %{state | blocks: [{file_index, block_indices} | state.blocks]}}
        else
          {remapped_indices, rest_free} = Enum.split(state.free, length(block_indices))
          remapped_indices = Enum.filter(remapped_indices, fn item -> item < block_head end)

          {leftover, _} =
            Enum.split(block_indices, length(block_indices) - length(remapped_indices))

          block = {file_index, remapped_indices ++ leftover}
          {:cont, %{state | free: rest_free, blocks: [block | state.blocks]}}
        end
      end
    )
    |> Kernel.then(fn map -> map.blocks end)
    |> checksum()
  end

  defp part_two(data) do
    data.blocks
    |> Enum.reduce_while(%{free: data.free, blocks: []}, fn {file_index, file_indices}, state ->
      size = length(file_indices)

      free_block_index =
        Enum.find_index(state.free, fn free_block ->
          length(free_block) >= size and hd(free_block) < hd(file_indices)
        end)

      if free_block_index !== nil do
        free_block = Enum.at(state.free, free_block_index)
        {remapped_indices, leftover_indices} = Enum.split(free_block, size)

        new_free =
          if leftover_indices !== [],
            do: List.replace_at(state.free, free_block_index, leftover_indices),
            else: List.delete_at(state.free, free_block_index)

        # IO.inspect(["Moved", file_index])

        {:cont,
         %{state | free: new_free, blocks: [{file_index, remapped_indices} | state.blocks]}}
      else
        {:cont, %{state | blocks: [{file_index, file_indices} | state.blocks]}}
      end
    end)
    |> Kernel.then(fn map -> map.blocks end)
    |> checksum()
  end

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "Input")
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
