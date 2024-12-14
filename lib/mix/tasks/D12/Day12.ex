# TODO: Redfactor.
# ---

# defmodule Mix.Tasks.Day12 do
#   require Timer
#   require InputUtils

#   @input "sample0.txt"

#   defp parse_input() do
#     __ENV__.file
#     |> InputUtils.read_all(@input)
#     |> String.split(~r/\n/, trim: true)
#     |> Enum.reduce(%{width: 0, height: 0, grid: %{}, labels: Map.new()}, fn row, map ->
#       row
#       |> String.graphemes()
#       |> Enum.with_index()
#       |> Enum.reduce(map, fn {cell, x}, map ->
#         y = Map.get(map, :height, 0)
#         labels = Map.update(map.labels, cell, 1, fn count -> count + 1 end)
#         %{map | width: x + 1, grid: Map.put(map.grid, [x, y], cell), labels: labels}
#       end)
#       |> Map.update(:height, 1, &(&1 + 1))
#     end)
#   end

#   def find_neighbors([cx, cy], positions) do
#     Enum.filter(positions, fn [nx, ny] ->
#       abs(nx - cx) + abs(ny - cy) === 1
#     end)
#   end

#   def map_edges_touched([cx, cy], size) do
#     [
#       cx - 1 < 0,
#       cx + 1 >= size.width,
#       cy - 1 < 0,
#       cy + 1 >= size.height
#     ]
#     |> Enum.count(fn condition -> condition end)
#   end

#   def find_perimeter([], _positions, _size, _visited, perimeter, border_points),
#     do: [perimeter, border_points]

#   def find_perimeter([current | queue], positions, size, visited, perimeter, border_points) do
#     if MapSet.member?(visited, current) do
#       find_perimeter(queue, positions, size, visited, perimeter, border_points)
#     else
#       visited = MapSet.put(visited, current)
#       all_neighbors = find_neighbors(current, positions)

#       unvisited_neighbors =
#         Enum.filter(all_neighbors, fn neighbor -> not MapSet.member?(visited, neighbor) end)

#       neighbors_count = length(all_neighbors)
#       perimeter = perimeter + (4 - neighbors_count)
#       border_points = if neighbors_count < 4, do: [current | border_points], else: border_points

#       find_perimeter(
#         queue ++ unvisited_neighbors,
#         positions,
#         size,
#         visited,
#         perimeter,
#         border_points
#       )
#     end
#   end

#   def is_neighbor?([cx, cy], [nx, ny], visited) do
#     abs(nx - cx) + abs(ny - cy) === 1 and not MapSet.member?(visited, [nx, ny])
#   end

#   def find_cluster([], _, _, cluster), do: cluster

#   def find_cluster([current | queue], positions, visited, cluster) do
#     if MapSet.member?(visited, current) do
#       find_cluster(queue, positions, visited, cluster)
#     else
#       visited = MapSet.put(visited, current)
#       neighbors = Enum.filter(positions, fn next -> is_neighbor?(current, next, visited) end)
#       find_cluster(queue ++ neighbors, positions, visited, [current | cluster])
#     end
#   end

#   def get_all_clusters([], _, clusters), do: clusters

#   def get_all_clusters(positions, size, clusters) do
#     cluster = find_cluster([hd(positions)], positions, MapSet.new(), [])

#     if cluster === [] do
#       clusters
#     else
#       new_positions =
#         Enum.filter(positions, fn position -> not Enum.member?(cluster, position) end)

#       get_all_clusters(new_positions, size, [cluster | clusters])
#     end
#   end

#   def create_edges(positions) do
#     positions
#     |> Enum.sort_by(fn [x, _y] -> x end, :asc)
#     |> Enum.sort_by(fn [_x, y] -> y end, :asc)
#     |> Enum.flat_map(fn [x, y] ->
#       [
#         {[x, y], [x + 1, y]},
#         {[x, y], [x, y + 1]},
#         {[x, y + 1], [x + 1, y + 1]},
#         {[x + 1, y], [x + 1, y + 1]}
#       ]
#     end)
#     |> Kernel.then(fn edges ->
#       freq = Enum.frequencies(edges)
#       Enum.reject(edges, fn edge -> Map.get(freq, edge) > 1 end)
#     end)
#     |> merge_edges()
#   end

#   def merge_edges(edges, merged \\ [])

#   def merge_edges([], merged), do: merged

#   def merge_edges([edge | tail], merged) do
#     IO.inspect(edge)
#     # TODO: Find all edges connected to the same points.
#     # Try to merge each, if they are colinear.
#     # Delete merged edges and add to merged.
#   end

#   defp part_one(map) do
#     map.labels
#     # |> Map.filter(fn {label, _count} -> label === "A" end)
#     |> Enum.reduce(0, fn {label, count}, price ->
#       positions =
#         map.grid
#         |> Map.filter(fn {_, position_label} -> position_label === label end)
#         |> Map.keys()

#       clusters = get_all_clusters(positions, %{width: map.width, height: map.height}, [])

#       prices =
#         clusters
#         |> Enum.map(fn cluster ->
#           [perimeter, border_points] =
#             find_perimeter(
#               [hd(cluster)],
#               cluster,
#               %{width: map.width, height: map.height},
#               MapSet.new(),
#               0,
#               []
#             )

#           create_edges(border_points)

#           perimeter * length(cluster)
#         end)

#       price + Enum.sum(prices)
#     end)
#   end

#   defp part_two(stones), do: :noop

#   def run(_) do
#     data = Timer.measure(fn -> parse_input() end, "Input")
#     p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
#     # p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
#     IO.puts("| Part one: #{p1_result} |")
#     # IO.puts("| Part two: #{p2_result} |")
#   end
# end
