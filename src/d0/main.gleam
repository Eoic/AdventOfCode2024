import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "src/d0/input/input.txt"

const output_path = "src/d0/output/output.txt"

pub fn main() {
  all_lines()
  io.println("---")
  each_line()
  io.println("---")
  write_lines()
}

fn all_lines() {
  case simplifile.read(input_path) {
    Ok(content) -> io.println(content)
    Error(_error) -> io.println("Failed to read file.")
  }
}

fn each_line() {
  let content = result.unwrap(simplifile.read(input_path), "")

  content
  |> string.split(on: "\n")
  |> list.index_map(with: fn(item, index) { #(1 + index, item) })
  |> list.each(fn(line) { io.println(int.to_string(line.0) <> ". " <> line.1) })
}

fn write_lines() {
  let list =
    list.range(0, 10)
    |> list.map(with: fn(num) { int.to_string(num * 5) })

  let assert Ok(_) =
    simplifile.write(to: output_path, contents: string.join(list, ", "))

  let assert Ok(_) =
    simplifile.append(to: output_path, contents: "\nAnd the some...")

  Nil
}
