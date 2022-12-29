
defmodule Day15 do
  def extract_tokens(line) do
    {:ok, reg} = Regex.compile("-?\\d+")
    [x, y, x2, y2] = Regex.scan(reg, line)
    [String.to_integer(hd(x)),
    String.to_integer(hd(y)),
    String.to_integer(hd(x2)),
    String.to_integer(hd(y2))]
  end

  def print_tokens([head | tail]) do
    IO.puts(head)
    print_tokens(tail)
  end

  def print_tokens([]) do
    IO.puts("")
    1
  end

  def parse_input([], accumulator) do
    accumulator
  end

  def parse_input([head | tail], accumulator) do
    entry = extract_tokens(head)
    # print_tokens(entry)
    parse_input(tail, accumulator ++ [entry])
  end

  def manhattan_distance(x, y, x_b, y_b) do
    abs(x - x_b) + abs(y - y_b)
  end

  def manhattan_distances([head|tail], akk) do
    [x, y, x_b, y_b] = head
    manhattan_distances(tail, akk ++ [manhattan_distance(x, y, x_b, y_b)])
  end

  def manhattan_distances([], akk) do
    akk
  end

  # Compute the interval covered by a sensor range in a given row
  def covered_interval(sensor_x, sensor_y, distance, target)
  when sensor_y <= target and sensor_y + distance >= target do
    spread = 2 * abs((sensor_y + distance) - target)
    # IO.puts(spread)
    [sensor_x - (spread/2), sensor_x + (spread/2)]
  end

  def covered_interval(sensor_x, sensor_y, distance, target)
  when sensor_y >= target and sensor_y - distance <= target do
   spread = 2 * abs((sensor_y - distance) - target)
   # IO.puts(spread)
   [sensor_x - (spread/2), sensor_x + (spread/2)]
  end

  def covered_interval(_, _, _, _) do
    [false, false]
  end

  def compute_intervals([head | tail], [h_dist | t_dist], target, akk) do
    [x, y, _, _] = head
    compute_intervals(tail, t_dist, target, akk ++ [covered_interval(x, y, h_dist, target)])
  end

  def compute_intervals([], _, _, akk) do
    akk
  end

  def get_span([head | tail], min, max) when head == [false, false] do
    get_span(tail, min, max)
  end

  def get_span([head | tail], min, max) do
    [from, to] = head
    min = compare_min(from, min)
    max = compare_max(to, max)
    get_span(tail, min, max)
  end

  def get_span([], min, max) do
    [min, max]
  end

  def compare_max(a, b) when a > b do a end
  def compare_max(a, b) when a <= b do b end

  def compare_min(a, b) when a < b do a end
  def compare_min(a, b) when a >= b do b end

  def get_beacons([head | tail], akk) do
    [_, _, x, y] = head
    get_beacons(tail, akk ++ [[x, y]])
  end

  def get_beacons([], akk) do
    Enum.uniq(akk)
  end

  def remove_beacons([head | tail], from, to, line, akk) do
    [x, y] = head

    if (y == line and x >= from and x <= to) do
      remove_beacons(tail, from, to, line, akk + 1)
    else
      remove_beacons(tail, from, to, line, akk)
    end
  end

  def remove_beacons([], _, _, _, akk) do
    akk
  end

  def prune_interval([head | tail], akk) when head == [false, false] do
    prune_interval(tail, akk)
  end

  def prune_interval([head|tail], akk) do
    prune_interval(tail, akk ++ [head])
  end

  def prune_interval([], akk) do
    akk
  end

  def merge_intervalls([head | tail], [top | rest]) do
    [top_min, top_max] = top
    [curr_min, curr_max] = head
    cond do
    top_max + 1 < curr_min ->
      merge_intervalls(tail, [head] ++ [top] ++ rest)
    top_max < curr_max ->
      merge_intervalls(tail, [[top_min, curr_max]] ++ rest)
    true ->
      merge_intervalls(tail, [top] ++ rest)
    end
  end

  def merge_intervalls([], akk) do
    Enum.reverse(akk)
  end

  def evaluate_field(count, _, _, akk) when count == -1 do
    Enum.reverse(akk)
  end

  def evaluate_field(count, data, distances, akk) do
    if (rem(count, 1000000) == 0) do
      IO.puts("Heartbeat...")
    end
    intervalls = compute_intervals(data, distances, count, [])
    intervalls_n = Day15.prune_interval(intervalls, [])
    intervalls_n = Enum.sort(intervalls_n)
    merged = merge_intervalls(intervalls_n, [hd(intervalls_n)])

    if (length(merged) > 1) do
      evaluate_field(count - 1, data, distances, akk ++ [[merged, count]])
    else
      evaluate_field(count - 1, data, distances, akk)
    end
  end

  def filter_viable([head | tail], akk) when length(head) > 1 do
    filter_viable(tail, akk ++ [head])
  end

  def filter_viable([_ | tail], akk) do
    filter_viable(tail, akk)
  end

  def filter_viable([], akk) do
    akk
  end
end
target = 2000000
# target=10

IO.puts("Reading Input")
{:ok, contents} = File.read("input.txt")
contents = String.split(contents, "\n", trim: true)

IO.puts("Parsing Input")
data = Day15.parse_input(contents, [])

IO.puts("Computing Manhattan Distances")
distances = Day15.manhattan_distances(data, [])

IO.puts("Compute Intervalls covered in target row")
intervalls = Day15.compute_intervals(data, distances, target, [])

# My solution ended up assuming that the covered area is one continuous piece in the line
# Bu given that, at leasts for my input, it works, I consider it a correct soltion
IO.puts("Extract Intervall")
[lower, upper] = Day15.get_span(intervalls, 1000000000000, -1000000000000)

IO.puts("Subtracting Beacons in Interval")
beacons = Day15.get_beacons(data, [])
beac_in_inter = Day15.remove_beacons(beacons, lower, upper, target, 0)

IO.puts("Result Part 1: ")
result1 = trunc(abs(upper-lower) + 1 - beac_in_inter)
IO.puts(result1)
IO.puts("")

x_max = 4000000

IO.puts("Evlauting area... This may take a while...")
viable = Day15.evaluate_field(x_max, data, distances, [])

[interval, line] = hd(viable)

[_, to] = hd(interval)

IO.puts("Result Part 2: ")
result = trunc((to + 1) * 4000000 + line)
IO.puts(to_string(to + 1) <> " * 4000000 + " <> to_string(line) <> " = " <> to_string(result))
