
Node = {name=0, flow_rate=0, targets=0, status=0}

function Node:new(id, flow_rate, targets)
   local o =  {}
   setmetatable(o, self)
   self.__index = self

   o.id = id or 0
   o.flow_rate = flow_rate or 0
   o.targets = targets or 0
   o.status = false

   return o
end

function Node:moves()
   possible = {}
   for k, reachable in pairs(self.targets) do
      possible[#possible + 1] = reachable
   end

   if not self.status then
       possible[#possible + 1] = "Open"
   end

   return possible
end

function Node:examine()
   print("\nExamining Node")
   print(string.format("\t Valve ID: %s", self.id))
   print(string.format("\t Flow Rate: %d", self.flow_rate))

   print("\t Reachable:")

   for k, reachable in pairs(self.targets) do
      print(string.format("\t\t Valve %s", reachable))
   end

   print("\t Status: " .. tostring(self.status))
   print("\n")
end

function read_input ()
   local lines = {}
   for line in io.lines("input.txt") do 
      lines[#lines + 1] = line
   end
   return lines
end

function parse_line (entry)
   local entry = entry:gsub(" valve ", " valves ")
   
   local valve_id = string.sub(entry, string.find(entry, "Valve ") + 6, string.find(entry, "Valve ") + 7)

   local flow_rate = tonumber(string.sub(entry, string.find(entry, "flow rate=") + 10, string.find(entry, ";") - 1))

   local targets = string.sub(entry, string.find(entry, "valves ") + 7)
   targets = string.gsub(targets, " ", "")

   local target_list = {}
   for value in string.gmatch(targets, "[A-Z]+") do
      target_list[#target_list + 1] = value
   end

   return Node:new(valve_id, flow_rate, target_list)
end

function parse_lines (input)
   local nodes = {}
   local entry = 0
   
   for k,v in pairs(input) do
      entry = parse_line(v)
      nodes[entry.id] = entry
   end

   return nodes
end

function generate_adj_matrix (nodes)
   local adj_matrix = {}

   for k, v in pairs(nodes) do
      for k2, v2 in pairs(nodes) do
         if adj_matrix[k] == nil then
            adj_matrix[k] = {}
         end

         adjacent = k == k2
         for _, neighbor in pairs(nodes[k].targets) do
            if neighbor == k2 then
               adjacent = true
            end
         end

         if(adjacent) then
            adj_matrix[k][k2] = 1
         else
            adj_matrix[k][k2] = 0
         end
      end
   end

   return adj_matrix
end

function generate_distance_matrix(nodes, adjacencies)
   local distance_matrix = {}

   for from, inner in pairs(adjacencies) do
      distance_matrix[from] = {}
   end

   for from, inner in pairs(adjacencies) do
      for to, adj in pairs(inner) do
         distance_matrix[from][to] = compute_distance(from, to, nodes)
      end
   end

   return distance_matrix
end

function construct_random_path(nodes)
   local viable = {}
   for key, value in pairs(nodes) do
      if value.flow_rate > 0 then
         viable[#viable + 1] = key
      end
   end

   shuffled = {}
   for i, v in ipairs(viable) do
      local pos = math.random(1, #shuffled+1)
      table.insert(shuffled, pos, v)
   end

   --for k, v in pairs(shuffled) do
   --   print(k .. " " .. v)
   --end

   return shuffled
end


-- Absolutely horrifying implementation, but works for the given size of nodes...
-- Give that this naive BFS basically falls into any loops, which this graph has plenty off, it's the main time consumer
-- But hey, it works on my machine :^)
function compute_distance(from, to, nodes)

   if from == to then
      return 1
   end
   
   local steps = 0
   local schedule = {}

   for _, v in pairs(nodes[from].targets) do
      schedule[#schedule + 1] = v
   end

   steps  = steps + 1

   local evaluated = {}
   local new_schedule = {}
   while  next(schedule) ~= nil do
      while next(schedule) ~= nil do
         k, v = next(schedule)
         if v == to then
            return steps
         end

         for _, target in pairs(nodes[v].targets) do
            local is_evaluated = false
            for _, v in pairs(evaluated) do
               if v == target then
                  is_evaluated = true
               end
            end

            if not is_evaluated then
               new_schedule[#new_schedule + 1] = target
               evaluated[#evaluated + 1] = target
            end
         end

         schedule[k] = nil
      end
      schedule = new_schedule
      new_schedule = {}
      steps = steps + 1
   end

   return -1
end

function print_matrix(matrix)
   keyset = {}
   io.write("   ")
   for k, v in pairs(matrix) do
      keyset[#keyset + 1] = k
      io.write(string.sub(k, 0, 1) .. " ")
   end
   io.write("\n")
   
   for _, key in pairs(keyset) do
      io.write(key .. " ")
      for _, key2 in pairs(keyset) do
         io.write(tostring(matrix[key][key2]) .. " ")
      end
      io.write("\n")
   end

   io.write("\n\n\n")
end

function explain_path(path, distances, nodes)
   local minute = 1
   local position = "AA"
   local sum = 0
   print("Minute 1")
   for _, next_pos in pairs(path) do
      print("Moving from " .. position .. " to " ..  next_pos .. " takes " .. tostring(distances[position][next_pos]) .. " minutes.")
      minute = minute + distances[position][next_pos] + 1
      print("Minute " .. tostring(minute))
      if minute >= 30 then
         print("Total " .. tostring(sum))
         return
      end

      local flow = (31 - minute) * nodes[next_pos].flow_rate
      sum = sum + flow
      print("Opening valve " .. next_pos .. " taking 1 minute and yielding " .. tostring(flow) .. " release.")
      position = next_pos
   end

   print("Total " .. tostring(sum))
end

function evaluate_path(path, distances, nodes)
   local minute = 1
   local position = "AA"
   local sum = 0
   for _, next_pos in pairs(path) do
      minute = minute + distances[position][next_pos] + 1
      if minute >= 30 then
         return sum
      end

      local flow = (31 - minute) * nodes[next_pos].flow_rate
      sum = sum + flow

      position = next_pos
   end

   return sum
end

function evaluate_paths(path_a, path_b, distances, nodes)
   local minute = 1
   local position = "AA"
   local sum = 0
   for _, next_pos in pairs(path_a) do
      minute = minute + distances[position][next_pos] + 1
      if minute >= 27 then
         break
      end

      local flow = (27 - minute) * nodes[next_pos].flow_rate
      sum = sum + flow

      position = next_pos
   end

   minute = 1
   position = "AA"
   for _, next_pos in pairs(path_b) do
      minute = minute + distances[position][next_pos] + 1
      if minute >= 27 then
         break
      end

      local flow = (27 - minute) * nodes[next_pos].flow_rate
      sum = sum + flow

      position = next_pos
   end

   return sum
end

-- Shoutouts to u/MagiMas for the lovely optimization theory based approach
-- Lots of learnings made here
function simulated_annealing(init_path, distances, nodes)
   local path = init_path
   local temperature = 100
   local pressure = evaluate_path(path, distances, nodes)
   --print("Initital Pressure is " .. tostring(pressure))
   --print("Path is: ")
   --for k, v in pairs(path) do
   --   io.write(v .. " ")
   --end
   --io.write("\n")
   local new_pressure = 0
   local i1, i2, save1, save2
   local length = #path

   while temperature > 0.001 do
      local old_path = path

      path = minimal_change(path)

      new_pressure = evaluate_path(path, distances, nodes)

      local rand_val = math.random()
      if new_pressure > pressure then
         pressure = new_pressure
      elseif (math.exp((new_pressure - pressure)/temperature) > rand_val) then
         pressure = new_pressure
      else
         path = old_path
      end

      temperature = temperature - 0.00001
   end

   --print("Final Pressure: " .. pressure)
   return path
end

function simulated_annealing2(path1, path2, distances, nodes)
   local path_a = path1
   local path_b = path2
   
   local temperature = 100
   local pressure = evaluate_paths(path_a, path_b, distances, nodes)
   --print("Initital Pressure is " .. tostring(pressure))
   --print("Paths are: ")
   --print_paths(path_a, path_b)
   local new_pressure = 0

   while temperature > 0.001 do
      --print("Paths are: ")
      --print_paths(path_a, path_b)
      local new_pressure = 0

      local path_a_old = {}
      local path_b_old = {}

      for k, v in pairs(path_a) do
         path_a_old[k] = v
      end

      for k, v in pairs(path_b) do
         path_b_old[k] = v
      end

      path_a, path_b = alter_paths(path_a, path_b)
      new_pressure = evaluate_paths(path_a, path_b, distances, nodes)

      local rand_val = math.random()
      if new_pressure > pressure then
         --print("Accept")
         pressure = new_pressure
      elseif (math.exp((new_pressure - pressure)/temperature) > rand_val) then
           --print("Accept")
           pressure = new_pressure
      else
         --print("Reject")
         path_a = path_a_old
         path_b = path_b_old
      end

      temperature = temperature - 0.0002
   end

   --print("Final Pressure: " .. pressure)
   --print("Paths are: ")
   --print_paths(path_a, path_b)
   return pressure
end

function minimal_change(path)
   if (#path <= 1) then
      return path
   end
    
   local new_path = {}

   for k, v in pairs(path) do
      new_path[#new_path + 1] = v
   end

   local random1 = math.random(1, #path)
   local random2 = math.random(1, #path)

   while random1 == random2 do
      random1 = math.random(1, #path)
      random2 = math.random(1, #path)
   end

   local temp = new_path[random1]
   new_path[random1] = new_path[random2]
   new_path[random2] = temp

   return new_path
end

function move_element(path_a, path_b)
   local path_a_new = {}
   local path_b_new = {}

   for k, v in pairs(path_a) do
      path_a_new[k] = v
   end

    for k, v in pairs(path_b) do
      path_b_new[k] = v
    end

    local i = 0
    local j = 0

    if #path_a == 0 then
       return path_a, path_b
    elseif #path_b == 0 then
       i = math.random(1, #path_a_new)
       local temp = table.remove(path_a_new, i)
       table.insert(path_b_new, temp)

       return path_a_new, path_b_new
    else
       while i == j do
          i = math.random(1, #path_a_new)
          j = math.random(1, #path_b_new)
       end
    end
    
    local temp = table.remove(path_a_new, i)
    table.insert(path_b_new, j, temp)

    return path_a_new, path_b_new
end

function alter_paths(path_a, path_b)
   local path_a_new = path_a
   local path_b_new = path_b

   local action = math.random(1, 4)

   if action == 1 then
      --print("1")
      path_a_new = minimal_change(path_a)
   elseif action == 2 then
      --print("2")
      path_b_new = minimal_change(path_b)
   elseif action == 3 then
      --print("3")
      path_a_new, path_b_new = move_element(path_a, path_b)
   elseif action == 4 then
      --print("4")
      path_b_new, path_a_new = move_element(path_b, path_a)
   end

   return path_a_new, path_b_new
end

function part1(nodes, distances)
   local init_path = construct_random_path(nodes)

   local path1 = simulated_annealing(init_path, distances, nodes)
   local path2 = simulated_annealing(init_path, distances, nodes)
   local path3 = simulated_annealing(init_path, distances, nodes)

   local solution_1 = evaluate_path(path1, distances, nodes)
   local solution_2 = evaluate_path(path2, distances, nodes)
   local solution_3 = evaluate_path(path3, distances, nodes)

   local solution = math.max(solution_1, solution_2, solution_3)
   print("Solutions (Keep in mind these are probabilistic, and you may have to run the script more than once")
   print("Solution 1: " .. solution)

end

function print_paths(path_a, path_b)
      print("Path A")
      for k, v in pairs(path_a) do
         io.write(k .. ": " .. v .. " -> ")
      end
      io.write("END\n")
      
      print("Path B")
      for k, v in pairs(path_b) do
         io.write(k .. ": " .. v .. " -> ")
      end
      io.write("END\n")
end

function part2(nodes, distances)
   local init_path = construct_random_path(nodes)

   path_a = {}
   path_b = {}

   for k,v in pairs(init_path) do
      if k % 2 == 0 then
         table.insert(path_a, v)
      else
         table.insert(path_b, v)
      end
   end

   return simulated_annealing2(path_a, path_b, distances, nodes)
end

function sample_part_2(nodes, distances) 
   local solution = 0

   for i = 0, 15, 1 do
      solution = math.max(solution, part2(nodes, distances))
   end
   
   print("Solutions (Keep in mind these are probabilistic, and you may have to run the script more than once")
   print("Solution 2: " .. solution)
end
   

math.randomseed(os.time())
print(".===============================.")
print("|           Day 16              |")
print(".===============================.")
local input = read_input()
local nodes = parse_lines(input)
local adj_matrix = generate_adj_matrix(nodes)

distances = generate_distance_matrix(nodes, adj_matrix)
--print_matrix(distances)

part1(nodes, distances)
sample_part_2(nodes, distances)




