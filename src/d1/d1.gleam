import gleam/int
import gleam/io
import gleam/list
import gleam/regexp as rgx
import gleam/result
import gleam/string
import simplifile

const input_sample = "src/d1/input_sample.txt"

const input_full = "src/d1/input_full.txt"

type Locations {
  Locations(left: List(Int), right: List(Int))
}

fn parse_input(path: String) {
  let assert Ok(split_pattern) = rgx.from_string("\\s+")
  let assert Ok(content) = simplifile.read(path)

  content
  |> string.trim()
  |> string.split(on: "\n")
  |> list.fold(from: Locations([], []), with: fn(memo, pair) {
    let items =
      pair
      |> rgx.split(with: split_pattern, content: _)
      |> list.map(fn(item) { result.unwrap(int.parse(item), 0) })

    Locations([result.unwrap(list.first(items), 0), ..memo.left], [
      result.unwrap(list.last(items), 0),
      ..memo.right
    ])
  })
}

fn sum_distances(data: Locations) {
  let left = list.sort(data.left, by: int.compare)
  let right = list.sort(data.right, by: int.compare)
  let sum_abs = fn(lhs, rhs) { int.absolute_value(lhs - rhs) }
  int.sum(list.map2(left, right, sum_abs))
}

fn sum_similarities(data: Locations) {
  list.fold(data.left, 0, with: fn(sum, item_left) {
    sum
    + list.count(data.right, fn(item_right) { item_left == item_right })
    * item_left
  })
}

fn part_one(data: Locations) {
  sum_distances(data)
}

fn part_two(data: Locations) {
  sum_similarities(data)
}

pub fn main() {
  let data = parse_input(input_full)

  data
  |> part_one
  |> int.to_string
  |> io.println

  data
  |> part_two
  |> int.to_string
  |> io.println
}
