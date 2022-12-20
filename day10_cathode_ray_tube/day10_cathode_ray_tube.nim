import std/strutils
import os

const interesting_cycles = {20, 60, 100, 140, 180, 220}
const crt_cols = 40
const crt_lines = 6

type
  InstructionKind = enum
    noop, addx

  Instruction = object
    itype: InstructionKind
    value: int

  CRTLine = array[crt_cols, char]
  CRTDisplay = array[crt_lines, CRTLine]

  CPU = object
    X: int
    cycle: int
    instructions:seq[Instruction]
    signalStrength: int
    display: CRTDisplay

proc readInput(): seq[string] =
  for line in lines "input.txt":
    result.add(line)
  result

proc parseInput(input: seq[string]): seq[Instruction] =
  for line in input:
    var tokens = line.split(' ')
    if tokens[0] == "addx":
      result.add(Instruction(itype: addx, value: parseInt(tokens[1])))
    else:
      result.add(Instruction(itype: noop, value: 0))
  return result

proc updateCrt(cpu : var CPU) =
  var line = cpu.cycle div crt_cols
  var col = cpu.cycle mod crt_cols

  if line >= 6:
    return

  # echo "Cycle is ", cpu.cycle, " so we draw in l:", line, " c:", col
  # echo "X is ", cpu.X
  
  if (cpu.X - 1)  <=  col and col <= (cpu.X + 1):
    # echo "Pixel is drawn"
    cpu.display[line][col] = '#'
  else:
    # echo "Pixel is discarded"
    cpu.display[line][col] = '.'

  # echo "Line ", line, " is now:"
  #for character in cpu.display[line]:
  #  stdout.write character
  #stdout.write "\n"
  
proc increaseCycles(cpu: var CPU, number: int) =
  if cpu.cycle == 0:
    updateCrt(cpu)
  for i in 1 .. number:
      cpu.cycle += 1
      if interesting_cycles.contains(cpu.cycle):
        echo "~ Interesting Freq -> ", cpu.X, " @ #", cpu.cycle
        cpu.signalStrength += cpu.X * cpu.cycle

      if i == 1:
        updateCrt(cpu)

proc renderDisplay(cpu: CPU) =
  for line in cpu.display:
    for character in line:
      stdout.write character
    stdout.write "\n"
      
proc evaluateInstruction(cpu: var CPU, instruction: Instruction) =
  if instruction.itype == addx:
    increaseCycles(cpu, 2)
    cpu.X += instruction.value
    updateCrt(cpu) # Doing this here is quite hacky, but time...
  else:
    increaseCycles(cpu, 1)
  
proc execute(cpu: CPU) =
  var cpu = cpu

  echo "~ Executing Instructions..."
  for instruction in cpu.instructions:
    # echo "Executing ", instruction
    # echo "Cycle count is ", cpu.cycle
    # echo "X is ", cpu.X
    evaluateInstruction(cpu, instruction)

  echo "~ Solution 1"
  echo "~ CPU Signal Strength -> ", cpu.signalStrength
  echo "~ Solution 2"
  renderDisplay(cpu)

echo ".====================================."
echo "|....................................|"
echo "|..............DAY.10................|"
echo "|.........Cathode-Ray.Tube...........|"
echo "|....................................|"
echo ".====================================."
echo ""
echo "~ Reading Input..."
var input = readInput()

echo "~ Parsing Input..."
var commandList = parseInput(input)
var cpu = CPU(X: 1, cycle: 0, instructions: commandList, signalStrength: 0)
execute(cpu)
