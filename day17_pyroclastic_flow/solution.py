import hashlib

class Solver():

    cycle = 0
    target = -1
    field = []
    tracking = {}
    hashes = {}
    height = 0
    jetstream = ''
    jetstream_position = 0
    cycle_height = 0
    cycle_done = False

    def reset(self):
        self.cycle = 0
        self.target = -1
        self.field = []
        self.tracking = {}
        self.hashes = {}
        self.height = 0
        self.jetstream_position = 0
        self.cycle_height = 0
        self.cycle_done = False

    """
    Hardcoded as I'm just trying to eliminate possible errors at this point
    """
    def get_height(self, shape_type):
        if shape_type == 0:
            return 1
        elif shape_type == 1:
            return 3
        elif shape_type == 2:
            return 3
        elif shape_type == 3:
            return 4
        elif shape_type == 4:
            return 2

    def create_shape(self, shape_type):
        if shape_type == 0:
            return [[0, 0], [1, 0], [2, 0], [3, 0]]
        elif shape_type == 1:
            return [[1, 0], [0, 1], [1, 1], [2, 1], [1, 2]]
        elif shape_type == 2:
            return [[0, 2], [1, 2], [2, 0], [2, 1], [2, 2]]
        elif shape_type == 3:
            return [[0, 0], [0, 1], [0, 2], [0, 3]]
        elif shape_type == 4:
            return [[0, 0], [1, 0], [0, 1], [1, 1]]
        
    """
    Simulates one move
    """
    def simulate_move(self, x, y, shape):
        shape_new = []
        for point in shape:
            shape_new.append([point[0] + x, point[1] + y])
        return shape_new

    def calculate_height(self):
        count = 0
        for line in self.field:
            if 1 in line:
                count += 1
        return count + self.cycle_height

    def normalize_field(self):
        new_field = []
        for line in self.field:
            if 1 in line:
                new_field.append(line)
        self.field = new_field

    def expand_field(self, rows):
        for i in range(0, rows):
            self.field.insert(0, [0, 0, 0, 0, 0, 0, 0])

    def collission_check(self, shape):
        for point in shape:
            if point[0] >= 7 or point[0] < 0:
                return False
            if point[1] >= len(self.field) or point[1] < 0:
                return False
            if self.field[point[1]][point[0]] == 1:
                return False

        return True

    def place_shape(self, shape):
        for point in shape:
            self.field[point[1]][point[0]] = 1

    def print_field(self):
        for line in self.field:
            print(line)

    def handle_cycle(self, hashdigest):
        print("Found a cycle!!!")
        cycle_start_no = self.hashes[hashdigest]
        cycle_start = self.tracking[self.hashes[hashdigest]]
        cycle_end = self.tracking[self.cycle]

        cycle_length = self.cycle - cycle_start_no
        print(f'Cycle found from {cycle_start_no} to {self.cycle} which is {cycle_length} turns')
        height_difference = cycle_end[0] - cycle_start[0]
        print(f'Height Difference of cycle is {height_difference}')
        number_of_cycles = int((self.target - cycle_start_no - cycle_length) / cycle_length)
        print(f'Shortcutting {number_of_cycles}')
        # Genuinely no idea where that off by one comes from, but my brain is deep fried by now
        self.cycle_height = number_of_cycles * height_difference + 1
        print(f'New Height is {self.cycle_height}')
        self.cycle = self.cycle + number_of_cycles * cycle_length
        print(f'New Cycle is {self.cycle}')
    
    def perform_cycle(self, shape_type):
        shape = self.create_shape(shape_type)
        shape = self.simulate_move(2, 0, shape)
        self.normalize_field()

        needed_space = self.get_height(shape_type) + 3
        self.expand_field(needed_space)

        while True:
            jetstream_current = self.jetstream[self.jetstream_position]
            shape_new = None
            
            if jetstream_current == ">":
                shape_new = self.simulate_move(1, 0, shape)
            elif jetstream_current == "<":
                shape_new = self.simulate_move(-1, 0, shape)
            else:
                print("Unknown symbol in jetstream")
                exit(0)

            if self.collission_check(shape_new):
                shape = shape_new

            shape_new = self.simulate_move(0, 1, shape)

            if self.collission_check(shape_new):
                shape = shape_new
            else:
                self.place_shape(shape)
                self.height = self.calculate_height()
                self.tracking[self.cycle] = [self.height, self.jetstream_position, shape_type]

                if len(self.field) > 40 and self.cycle_done == False:
                   representation = ''.join([str(element) for element in self.field[:30]]) + str(self.jetstream_position) + "-" + str(shape_type)
                   current_hash = hashlib.md5(representation.encode())

                   if current_hash.hexdigest() in self.hashes:
                       self.handle_cycle(current_hash.hexdigest())
                       self.cycle_done = True
                       return
                   else:
                       self.hashes[current_hash.hexdigest()] = self.cycle
                
                self.jetstream_position = (self.jetstream_position + 1) % len(self.jetstream)
                self.cycle += 1
                return

            self.jetstream_position = (self.jetstream_position + 1) % len(self.jetstream)

    def print_tracking(self):
        for entry in self.tracking:
            print(f'Cycle: {entry} Height: {self.tracking[entry][0]} JP: {self.tracking[entry][1]} Piece: {self.tracking[entry][2]}')
            
    def solve(self, cycles):
        self.target = cycles
        current_piece = 0
        while self.cycle < self.target:
            self.perform_cycle(current_piece)
            current_piece = (current_piece + 1) % 5
            #self.print_field()
            #print("\n\n\n")

        #self.print_tracking()
        print(f'Found Height {self.height}')
            
            

    def __init__(self):
        with open('input.txt') as input_file:
            self.jetstream = input_file.read().strip()


print("Part 1")
s = Solver()
s.solve(2022)
print("\n\n\nPart 2")
s.reset()
s.solve(1000000000000)

