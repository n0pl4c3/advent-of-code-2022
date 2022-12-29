#!/usr/bin/env ruby

class BridgeSimulator

  def initialize()
    @input = Array.new
    @commands = Array.new
    @new_commands = Array.new
    @visited = Array.new

    @head_x = 0
    @head_y = 0
    @tail_x = 0
    @tail_y = 0

    visit(@tail_x, @tail_y)
  end

  # Read Input File line by line
  def read_input()
    File.readlines('input.txt').each do |line|
      @input.append(line)
    end
  end

  def parse_input()
    for line in @input
      tokens = line.split
      case tokens[0]
      when 'R'
        i = 0
        while i < Integer(tokens[1]) do
          @commands.append([1,0])
          i += 1
        end
      when 'L'
        i = 0
        while i < Integer(tokens[1]) do
          @commands.append([-1,0])
          i += 1
        end
      when 'U'
        i = 0
        while i < Integer(tokens[1]) do
          @commands.append([0,1])
          i += 1
        end
      when 'D'
        i = 0
        while i < Integer(tokens[1]) do
          @commands.append([0,-1])
          i += 1
        end
      end
    end
  end

  # Print Input Lines
  def print_input()
    @input.each { |line| puts line }
  end

  # Moves head by instruction in line
  def move_head(command)
    @head_x += command[0]
    @head_y += command[1]
    adjust_tail()
  end

  # Executes all movements specified in input
  def execute()
    @commands.each do |instruction|
      move_head(instruction)
    end
  end

  # Add point to visited list if not in there
  def visit(x, y)
    if !(@visited.include? [x, y])
      @visited.append([x, y])
    end
  end

  # Print visited squares by tail
  def print_visited()
    puts "Visited: #{@visited}"
  end

  def reset()
    @commands = @new_commands
    @new_commands = []

    @head_x = 0
    @head_y = 0
    @tail_x = 0
    @tail_y = 0

    @visited = Array.new
    visit(@tail_x, @tail_y)
  end

  # Fetch the amount of positions visited
  def count_visited()
    @visited.count
  end
  
  # Move Tail to match Head movements
  # Ugly solution, but if it works it works
  def adjust_tail()
    movement = [0, 0]
    
    if !(@tail_x.between?(@head_x - 1, @head_x + 1) && @tail_y.between?(@head_y - 1, @head_y + 1))
      if @tail_x < (@head_x - 1) && @tail_y == @head_y
        @tail_x += 1
        movement = [1,0]
      elsif @tail_x == @head_x && @tail_y < (@head_y - 1)  
        @tail_y += 1
        movement = [0,1]
      elsif @tail_x > (@head_x + 1) && @tail_y == @head_y
        @tail_x -= 1
        movement = [-1,0]
      elsif @tail_x == @head_x && @tail_y > (@head_y + 1)
        @tail_y -= 1
        movement = [0,-1]
      elsif @tail_x > @head_x && @tail_y > @head_y
        @tail_x -= 1
        @tail_y -= 1
        movement = [-1,-1]
      elsif @tail_x > @head_x && @tail_y < @head_y
        @tail_x -= 1
        @tail_y += 1
        movement = [-1,1]
      elsif @tail_x < @head_x && @tail_y > @head_y
        @tail_x += 1
        @tail_y -= 1
        movement = [1,-1]
      elsif @tail_x < @head_x && @tail_y < @head_y
        @tail_x += 1
        @tail_y += 1
        movement = [1,1]
      end

      visit(@tail_x, @tail_y)
    end

    @new_commands.append(movement)
  end

  # Prints current Head and Tail position
  def print_positions()
    puts "Head X: #{@head_x} Head Y: #{@head_y}"
    puts "Tail X: #{@tail_x} Tail Y: #{@tail_y}"
  end
end


if __FILE__ == $0
  sim = BridgeSimulator.new()

  puts ".==============================."
  puts "|         START PART 1         |"
  puts ".==============================.\n"
  puts "> Reading Input...\n"
  sim.read_input()
  puts "> Parsing Input...\n"
  sim.parse_input()
  puts ".==============================."
  puts "|           INPUT              |"
  puts ".==============================.\n"
  #sim.print_input()
  puts ".==============================."
  puts "|          POSITIONS           |"
  puts ".==============================.\n"
  sim.print_positions()
  puts ".==============================."
  puts "|          SIMULATE            |"
  puts ".==============================.\n"
  puts "> Simulating Movements...\n"
  sim.execute()
  puts ".==============================."
  puts "|          POSITIONS           |"
  puts ".==============================.\n"
  sim.print_positions()
  puts ".==============================."
  puts "|          VISITED             |"
  puts ".==============================.\n"
  #sim.print_visited()
  puts"> Visited #{sim.count_visited} Fields"
  puts ".==============================."
  puts "|         START PART 2         |"
  puts ".==============================.\n"

  i = 2
  while i < 10
  puts "\n\n.==============================."
  puts "|           ROPE  #{i}            |"
  puts ".==============================.\n"
  puts "> Resetting...\n"
  sim.reset()
  puts "> Starting Positions..."
  sim.print_positions()
  puts "> Simulating..."
  sim.execute()
  puts "> Positions...\n"
  sim.print_positions()
  i += 1
  end

  puts ".==============================."
  puts "|          VISITED             |"
  puts ".==============================.\n"
  #sim.print_visited()
  puts"> Visited #{sim.count_visited} Fields"
end
